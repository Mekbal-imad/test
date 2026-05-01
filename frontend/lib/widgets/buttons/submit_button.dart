import 'package:flutter/material.dart';
import 'package:job_bit/theme/app_theme.dart';

class SubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback? onPressed;

  const SubmitButton({super.key, required this.formKey, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.paddingMedium,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            if (onPressed != null) {
              onPressed!();
              return;
            }
            if (formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Form submitted successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },

child: const Text('Continue'),
        ),
      ),
    );
  }
}
