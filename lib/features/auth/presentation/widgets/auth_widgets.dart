import 'package:flutter/material.dart';
import '../../../../core/colors.dart';

/// INPUT FIELD
class AuthTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const AuthTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}

/// BUTTON
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AuthButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.all(14),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}

/// LINK TEXT (LOGIN ↔ REGISTER)
class AuthLink extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const AuthLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}