# ============================================
# Follow-up LoRA Tester (fixed)
# - Properly slices off the prompt before decoding
# - Maps roles to user/assistant for Qwen chat template
# ============================================

import os, json, re, random
import torch
from typing import List, Dict
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

# Use the same dir you trained to:
ADAPTER_DIR = "followuplora"   # <-- adjust if needed
assert os.path.exists(ADAPTER_DIR), f"Adapter dir not found: {ADAPTER_DIR}"

def detect_base_model(adapter_dir: str) -> str:
    meta_path = os.path.join(adapter_dir, "adapter_meta.json")
    if os.path.exists(meta_path):
        try:
            return json.load(open(meta_path, "r", encoding="utf-8"))["base_model"]
        except Exception:
            pass
    return "Qwen/Qwen2.5-0.5B-Instruct"

BASE_MODEL = detect_base_model(ADAPTER_DIR)
print("Using base model:", BASE_MODEL)

has_gpu = torch.cuda.is_available()
dtype = torch.float16 if has_gpu else torch.float32
device_map = "auto" if has_gpu else {"": "cpu"}

tok = AutoTokenizer.from_pretrained(BASE_MODEL, use_fast=True, trust_remote_code=True)
if tok.pad_token is None:
    tok.pad_token = tok.eos_token

base = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL,
    torch_dtype=dtype,
    device_map=device_map,
    trust_remote_code=True,
    low_cpu_mem_usage=True
)
model = PeftModel.from_pretrained(base, ADAPTER_DIR)
model.eval()

SYS_MSG = (
    "You are a clinical assistant. Output ONLY a single follow-up question to the patient. "
    "Keep it concise (max 20 words). Do not provide diagnoses, reassurance, or instructions; ask a question. "
    "End the sentence with a question mark."
)

def map_roles_for_qwen(history: List[Dict[str,str]]) -> List[Dict[str,str]]:
    """
    Convert custom roles to Qwen-friendly roles.
    - 'patient' -> 'user'
    - 'assistant' stays 'assistant'
    - 'doctor' (if present) -> 'assistant'
    - everything else -> 'user'
    """
    mapped = []
    for m in history:
        r = m.get("role","user").lower()
        if r == "assistant":
            role = "assistant"
        elif r == "doctor":
            role = "assistant"
        elif r == "patient":
            role = "user"
        else:
            role = "user"
        mapped.append({"role": role, "content": m.get("content","")})
    return mapped

def make_prompt(messages: List[Dict[str,str]]) -> str:
    if hasattr(tok, "apply_chat_template"):
        return tok.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    # Fallback plain format (rarely used with Qwen)
    lines = []
    for m in messages:
        role = m["role"].upper()
        lines.append(f"{role}: {m['content']}")
    lines.append("ASSISTANT: ")
    return "\n".join(lines)

def postprocess(text: str) -> str:
    text = text.strip()
    # Keep first sentence-ish bit
    seg = re.split(r"(?<=[\?\.\!])\s+", text, maxsplit=1)[0].strip()
    # Force question mark if missing
    if not seg.endswith("?"):
        qpos = seg.find("?")
        seg = seg[:qpos+1].strip() if qpos != -1 else (seg.rstrip(".! ") + "?").strip()
    # Enforce ≤ 20 words
    words = seg.split()
    if len(words) > 20:
        seg = " ".join(words[:20]) + "?"
    return seg

@torch.inference_mode()
def gen_one_question(history: List[Dict[str,str]], max_new_tokens=32, temperature=0.8, top_p=0.9) -> str:
    # Map roles to user/assistant
    mapped_hist = map_roles_for_qwen(history)
    messages = [{"role":"system","content":SYS_MSG}] + mapped_hist
    prompt = make_prompt(messages)

    inputs = tok([prompt], return_tensors="pt")
    if has_gpu:
        inputs = {k: v.cuda() for k, v in inputs.items()}

    out = model.generate(
        **inputs,
        max_new_tokens=max_new_tokens,
        do_sample=True,
        temperature=temperature,
        top_p=top_p,
        eos_token_id=tok.eos_token_id,
        pad_token_id=tok.eos_token_id
    )

    # ---- CRITICAL FIX: decode only the generated continuation, not the whole prompt ----
    gen_ids = out[0][inputs["input_ids"].shape[1]:]
    decoded = tok.decode(gen_ids, skip_special_tokens=True)

    return postprocess(decoded)

def gen_two_distinct_questions(history: List[Dict[str,str]]) -> List[str]:
    candidates = set()
    attempts = 0
    while len(candidates) < 2 and attempts < 6:
        attempts += 1
        q = gen_one_question(
            history,
            temperature=0.7 + 0.2*random.random(),
            top_p=0.85 + 0.1*random.random(),
        )
        candidates.add(q)
    return list(candidates)[:2]

print("\nInteractive tester ready.")
print("Type the PATIENT message and press Enter.")
print("I'll suggest 2 follow-up questions each turn.")
print("Commands: '/reset' to clear context, 'q' to quit.\n")

dialog_history: List[Dict[str,str]] = []

try:
    while True:
        user = input("Patient: ").strip()
        if user.lower() in {"q", "quit", "exit"}:
            print("Bye!")
            break
        if user.strip() == "/reset":
            dialog_history = []
            print("Context reset.\n")
            continue

        dialog_history.append({"role": "patient", "content": user})

        qs = gen_two_distinct_questions(dialog_history)
        for i, q in enumerate(qs, start=1):
            print(f"Q{i}: {q}")
            # Optionally add the assistant’s question into history to keep context:
            dialog_history.append({"role": "assistant", "content": q})
        print()

except KeyboardInterrupt:
    print("\nInterrupted. Goodbye!")
