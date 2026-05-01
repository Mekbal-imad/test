import 'package:flutter/material.dart';

class EmptyJobsFeed extends StatelessWidget {
  const EmptyJobsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Define theme lookups
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline, 
            size: 64, 
            color: cs.onSurface.withValues(alpha: 0.4), // Replaces hardcoded Colors.grey[400]
          ),
          const SizedBox(height: 16), // Added const
          Text(
            "No jobs available yet", 
            style: textTheme.titleLarge, // Replaces AppTheme.headingMedium
          ),
          const SizedBox(height: 8), // Added const
          Text(
            "Jobs will appear here soon", 
            style: textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6), 
            ), // Replaces AppTheme.bodyMedium
          ),
        ],
      ),
    );
  }
}