# ============================================================
# Follow-up Question Generator — LoRA SFT (No bitsandbytes/triton)
# One-cell Colab script for FREE tier CPU/GPU. Just run this cell.
#
# Expects your CSV at: /content/conversation_data.csv  (header allowed)
# Columns (flexible): id, patient, doctor   (also accepts Patient_Answer/user & Doctor_response/assistant)
# Saves model adapter to: /content/followup-lora
# ============================================================

import os, sys, csv, json, subprocess
from typing import List, Dict, Tuple
from collections import defaultdict

# -----------------------
# User-editable settings:
# -----------------------
dataPath = "/content/conversation_data.csv"   # <-- upload your CSV here (header allowed)
outputDir = "/content/followup-lora"          # <-- artifacts will be saved here

# Small models only (safe for free Colab):
candidateBaseModels = [
    "Qwen/Qwen2.5-0.5B-Instruct",   # safest for CPU
    "Qwen/Qwen2.5-1.5B-Instruct",   # still OK, faster on GPU
]

# Base hyperparams (we’ll auto-tune below for CPU/GPU)
maxSeqLen       = 768   # trimmed to fit tiny models on CPU too
epochs          = 2
trainBatchPerDev= 1     # conservative for free tier
gradAccum       = 16    # accumulate to get effective batch
lr              = 1e-4
loraR           = 8
loraAlpha       = 16
loraDropout     = 0.05
saveSteps       = 999_999   # disable frequent checkpointing
loggingSteps    = 50
seed            = 42

# --------------------------------
# 1) Minimal dependency installer
# --------------------------------
def pipInstall(pkgs: List[str]):
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-q"] + pkgs)

print("Installing/confirming dependencies (few mins on first run)…")
pipInstall([
    "transformers==4.44.2",
    "datasets==2.20.0",
    "accelerate==0.34.2",
    "peft==0.12.0",
    "trl==0.10.1"
])

# -------------------------------
# 2) Data: CSV → SFT chat pairs
# -------------------------------
def loadConvosFromCsv(csvPath: str) -> Dict[str, List[Tuple[str, str]]]:
    if not os.path.exists(csvPath):
        raise FileNotFoundError(f"CSV/TSV not found at {csvPath}")

    def pick(row, keys, default=""):
        for k in keys:
            if k in row and row[k] is not None:
                return str(row[k])
        return default

    byId = defaultdict(list)
    n_rows = 0
    n_kept = 0

    with open(csvPath, "r", encoding="utf-8", newline="") as f:
        # --- Detect delimiter (tab vs comma) and header ---
        sample = f.read(4096)
        f.seek(0)
        try:
            dialect = csv.Sniffer().sniff(sample, delimiters=",\t;|")
            has_header = csv.Sniffer().has_header(sample)
        except Exception:
            dialect = csv.get_dialect("excel")
            dialect.delimiter = "\t" if "\t" in sample else ","
            has_header = True

        if has_header:
            reader = csv.DictReader(f, dialect=dialect)
            for row in reader:
                n_rows += 1
                rid     = pick(row, ["id","ID","Id"]).strip()
                patient = pick(row, ["patient","Patient","Patient_Answer","user","customer"]).strip()
                doctor  = pick(row, ["doctor","Doctor","Doctor_response","assistant","question"]).strip()
                if rid and (patient or doctor):
                    byId[rid].append((patient, doctor))
                    n_kept += 1
        else:
            reader = csv.reader(f, dialect=dialect)
            for row in reader:
                n_rows += 1
                if not row or len(row) < 3: continue
                rid     = (row[0] or "").strip()
                patient = (row[1] or "").strip()
                doctor  = (row[2] or "").strip()
                if rid and (patient or doctor):
                    byId[rid].append((patient, doctor))
                    n_kept += 1

    print(f"[CSV] rows read: {n_rows}, kept: {n_kept}, conversations: {len(byId)}")
    return byId

def buildSftPairs(
    byId: Dict[str, List[Tuple[str, str]]],
    maxTurnsPerExample: int = 40,
    maxHistoryTurns: int = 8,
    minQuestionLen: int = 3
) -> List[Dict]:
    pairs = []
    sysMsg = (
        "You are a clinical assistant. Output ONLY the next, single best follow-up question to the patient. "
        "Keep it concise (max 20 words). Do not provide diagnoses, reassurance, or instructions; ask a question. "
        "End the sentence with a question mark."
    )
    for _, turns in byId.items():
        running = []
        used = 0
        for (patientUtterance, doctorQuestion) in turns:
            if patientUtterance:
                running.append({"role": "patient", "content": patientUtterance})

            if doctorQuestion:
                dq = doctorQuestion.strip()
                if len(dq) >= minQuestionLen and ("?" in dq or dq.endswith("?")):
                    trimmed = running[-maxHistoryTurns:] if maxHistoryTurns > 0 else running
                    messages = [{"role": "system", "content": sysMsg}] + trimmed + [
                        {"role": "assistant", "content": dq}
                    ]
                    pairs.append({"messages": messages})
                    used += 1
                    if maxTurnsPerExample > 0 and used >= maxTurnsPerExample:
                        break
                # append as a 'doctor' role to history for context drift
                running.append({"role": "doctor", "content": doctorQuestion})
    return pairs

def saveJsonl(pairs: List[Dict], outPath: str):
    os.makedirs(os.path.dirname(outPath), exist_ok=True)
    with open(outPath, "w", encoding="utf-8") as w:
        for ex in pairs:
            w.write(json.dumps(ex, ensure_ascii=False) + "\n")

# -------------------------------
# 3) Dataset (HF datasets)
# -------------------------------
def buildDataset(jsonlPath: str, seed: int = 42, splitTrain: float = 0.95):
    from datasets import load_dataset
    ds = load_dataset("json", data_files=jsonlPath, split="train")
    if splitTrain and 0.0 < splitTrain < 1.0:
        ds = ds.train_test_split(test_size=1.0 - splitTrain, seed=seed)
        return ds["train"], ds["test"]
    return ds, None

# -------------------------------
# 4) Device strategy (no BnB)
# -------------------------------
import torch
hasGpu = torch.cuda.is_available()
print("GPU available:", hasGpu)

# Slightly friendlier defaults if GPU exists (still small models)
if hasGpu:
    maxSeqLen        = 1024
    trainBatchPerDev = 2
    gradAccum        = 8

# ------------------------------------
# 5) Training (LoRA + TRL SFTTrainer)
# ------------------------------------
def tryLoadBaseModel(modelName: str):
    from transformers import AutoModelForCausalLM
    if hasGpu:
        print(f"Loading {modelName} on GPU with fp16…")
        return AutoModelForCausalLM.from_pretrained(
            modelName,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True,
            low_cpu_mem_usage=True,
        )
    else:
        print(f"Loading {modelName} on CPU (fp32)…")
        return AutoModelForCausalLM.from_pretrained(
            modelName,
            torch_dtype=torch.float32,
            device_map={"": "cpu"},
            trust_remote_code=True,
            low_cpu_mem_usage=True,
        )

def trainLoraSft(
    baseModel: str,
    trainJsonl: str,
    outDir: str,
    maxSeqLen: int,
    epochs: int,
    trainBatchPerDev: int,
    gradAccum: int,
    lr: float,
    loraR: int,
    loraAlpha: int,
    loraDropout: float,
    saveSteps: int,
    loggingSteps: int,
    seed: int
):
    from transformers import AutoTokenizer
    from trl import SFTTrainer, SFTConfig
    from peft import LoraConfig

    print("Loading tokenizer…")
    tok = AutoTokenizer.from_pretrained(baseModel, use_fast=True, trust_remote_code=True, padding_side="left")
    if tok.pad_token is None:
        tok.pad_token = tok.eos_token

    print("Loading base model… (no bitsandbytes)")
    model = tryLoadBaseModel(baseModel)

    # Memory safety knobs
    try:
        model.gradient_checkpointing_enable()
    except Exception:
        pass

    print("Building dataset…")
    trainDs, evalDs = buildDataset(trainJsonl, seed=seed, splitTrain=0.95)

    # Target modules set robustly for Qwen; non-existent names are ignored
    targetMods = ["q_proj","k_proj","v_proj","o_proj","up_proj","down_proj","gate_proj"]
    loraCfg = LoraConfig(
        r=loraR,
        lora_alpha=loraAlpha,
        target_modules=targetMods,
        lora_dropout=loraDropout,
        bias="none",
        task_type="CAUSAL_LM",
    )

    bf16_ok = torch.cuda.is_bf16_supported() if hasGpu else False
    trainCfg = SFTConfig(
        output_dir=outDir,
        num_train_epochs=epochs,
        per_device_train_batch_size=trainBatchPerDev,
        gradient_accumulation_steps=gradAccum,
        learning_rate=lr,
        logging_steps=loggingSteps,
        save_steps=saveSteps,
        save_total_limit=2,
        optim="adamw_torch",     # no paged_adamw (bnb-free)
        bf16=bf16_ok,            # only if GPU supports bf16
        fp16=hasGpu and not bf16_ok,  # fp16 on GPU if bf16 not available
        max_seq_length=maxSeqLen,
        packing=True,
        seed=seed,
        report_to=[]
    )

    print("Starting SFT…")
    trainer = SFTTrainer(
        model=model,
        tokenizer=tok,
        train_dataset=trainDs,
        eval_dataset=evalDs,
        peft_config=loraCfg,
        args=trainCfg,
        formatting_func=None,
    )
    trainer.train()

    print("Saving LoRA adapter + tokenizer…")
    os.makedirs(outDir, exist_ok=True)
    trainer.model.save_pretrained(outDir)
    tok.save_pretrained(outDir)
    print(f"Saved to: {outDir}")

# -------------------------------
# 6) Inference sanity utilities
# -------------------------------
def writeAdapterMeta(adapterDir: str, baseModel: str):
    with open(os.path.join(adapterDir, "adapter_meta.json"), "w", encoding="utf-8") as w:
        json.dump({"base_model": baseModel}, w, ensure_ascii=False, indent=2)

def detectBaseFromAdapter(adapterDir: str) -> str:
    p = os.path.join(adapterDir, "adapter_meta.json")
    if os.path.exists(p):
        try:
            return json.load(open(p, "r", encoding="utf-8"))["base_model"]
        except Exception:
            pass
    return candidateBaseModels[0]

def generateNextQuestion(adapterDir: str, promptHistory: List[Dict], maxNewTokens: int = 32) -> str:
    from transformers import AutoModelForCausalLM, AutoTokenizer
    from peft import PeftModel

    baseModel = detectBaseFromAdapter(adapterDir)
    tok = AutoTokenizer.from_pretrained(baseModel, use_fast=True, trust_remote_code=True)
    if tok.pad_token is None:
        tok.pad_token = tok.eos_token

    # Load base (no quantization libs)
    if hasGpu:
        base = AutoModelForCausalLM.from_pretrained(
            baseModel, torch_dtype=torch.float16, device_map="auto", trust_remote_code=True
        )
    else:
        base = AutoModelForCausalLM.from_pretrained(
            baseModel, torch_dtype=torch.float32, device_map={"": "cpu"}, trust_remote_code=True
        )
    model = PeftModel.from_pretrained(base, adapterDir)
    model.eval()

    sysMsg = (
        "You are a clinical assistant. Output ONLY the next, single best follow-up question to the patient. "
        "Keep it concise (max 20 words). Do not provide diagnoses, reassurance, or instructions; ask a question. "
        "End the sentence with a question mark."
    )
    messages = [{"role": "system", "content": sysMsg}] + promptHistory

    if hasattr(tok, "apply_chat_template"):
        inputText = tok.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    else:
        inputText = "\n".join([f"{m['role'].upper()}: {m['content']}" for m in messages]) + "\nASSISTANT: "

    inputs = tok([inputText], return_tensors="pt")
    if hasGpu:
        inputs = {k: v.cuda() for k, v in inputs.items()}

    with torch.no_grad():
        out = model.generate(
            **inputs,
            max_new_tokens=maxNewTokens,
            do_sample=True,
            temperature=0.7,
            top_p=0.9,
            eos_token_id=tok.eos_token_id
        )
    gen = tok.decode(out[0], skip_special_tokens=True)
    if "ASSISTANT:" in gen:
        gen = gen.split("ASSISTANT:")[-1].strip()
    return gen.split("\n")[0].strip()

# -------------------------------
# 7) End-to-end runner
# -------------------------------
def main():
    # 1) Build JSONL from CSV
    print(f"Loading CSV from: {dataPath}")
    byId = loadConvosFromCsv(dataPath)
    pairs = buildSftPairs(byId)
    jsonlPath = os.path.join(outputDir, "train.jsonl")
    os.makedirs(outputDir, exist_ok=True)
    saveJsonl(pairs, jsonlPath)
    print(f"Prepared {len(pairs)} SFT messages → {jsonlPath}")

    # 2) Pick the first base model that loads cleanly
    baseModel = None
    lastErr = None
    for name in candidateBaseModels:
        try:
            print(f"Probing base model: {name}")
            _ = tryLoadBaseModel(name)   # load + free immediately
            del _
            if torch.cuda.is_available():
                torch.cuda.empty_cache()
            baseModel = name
            print(f"Using base model: {baseModel}")
            break
        except Exception as e:
            lastErr = e
            print(f"Failed to load {name}: {e}")

    if baseModel is None:
        raise RuntimeError(f"Could not load any base model. Last error: {lastErr}")

    # 3) Train LoRA SFT
    trainLoraSft(
        baseModel=baseModel,
        trainJsonl=jsonlPath,
        outDir=outputDir,
        maxSeqLen=maxSeqLen,
        epochs=epochs,
        trainBatchPerDev=trainBatchPerDev,
        gradAccum=gradAccum,
        lr=lr,
        loraR=loraR,
        loraAlpha=loraAlpha,
        loraDropout=loraDropout,
        saveSteps=saveSteps,
        loggingSteps=loggingSteps,
        seed=seed
    )

    # 4) Save adapter meta (helps inference auto-detect base)
    writeAdapterMeta(outputDir, baseModel)

    # 5) Tiny sanity gen (optional)
    try:
        demoHistory = [
            {"role":"patient","content":"I’ve had a dull headache for 3 days and mild fever."}
        ]
        print("Quick sanity check generation:")
        print("→", generateNextQuestion(outputDir, demoHistory))
    except Exception as e:
        print("Generation sanity check skipped due to error:", e)

# ---- Run everything ----
if __name__ == "__main__":
    main()
