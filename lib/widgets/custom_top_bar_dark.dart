import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Needed for System UI control

class CustomTopBarDark extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomTopBarDark({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onBack,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    const accentDark = Color(0xFF016969);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: accentDark, // ✅ makes battery/signal area same color
        statusBarIconBrightness: Brightness.light, // ✅ white icons for Android
        statusBarBrightness: Brightness.dark, // ✅ for iOS
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        decoration: BoxDecoration(
          color: accentDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ⬅ Back button + title
              Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 22, color: Colors.white),
                      onPressed: onBack ?? () => Navigator.pop(context),
                    ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),

              // 👤 Profile + 🔔 Notifications
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 26),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
