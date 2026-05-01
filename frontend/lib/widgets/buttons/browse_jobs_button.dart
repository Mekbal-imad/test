import 'package:flutter/material.dart';

class BrowseJobsButton extends StatelessWidget {
  const BrowseJobsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 52, 
      child: ElevatedButton(
        onPressed: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        child: const Text(
          'Browse Jobs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}