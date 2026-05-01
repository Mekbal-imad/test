import 'package:flutter/material.dart';
import 'package:job_bit/widgets/buttons/browse_jobs_button.dart';

class EmptySavedJobs extends StatelessWidget {
  const EmptySavedJobs({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
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
              Icons.bookmark_border, 
              size: 48, 
              color: cs.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Saved Jobs Yet", 
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Start saving jobs you're interested in to easily find them later",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const BrowseJobsButton(),
        ],
      ),
    );
  }
}