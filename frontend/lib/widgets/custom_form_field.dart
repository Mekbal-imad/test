import 'package:flutter/material.dart';

typedef Validator = String? Function(String?);

class CustomFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType keyboardType;
  final Validator? validator;
  final int maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool isRequired;

  const CustomFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: cs.primary) : null,
            suffixIcon: suffixIcon,
          ),
          validator: validator ??
              (value) {
                if (isRequired && (value == null || value.trim().isEmpty)) {
                  return 'This field is required';
                }
                return null;
              },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}