import 'package:flutter/material.dart';

class EmptyPostedJobs extends StatelessWidget {
  const EmptyPostedJobs({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Define theme lookups
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column( // Removed Container(color: Colors.grey[100]) to let theme handle background
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 48,
              color: cs.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Posted Jobs Yet", 
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "You haven't posted any jobs yet. Start posting jobs to find the right candidates.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/post-job'),
            icon: const Icon(Icons.add),
            label: const Text("Post a Job"),
            // style: Removed manual styling as per B11; theme handles this now
          ),
        ],
      ),
    );
  }
}