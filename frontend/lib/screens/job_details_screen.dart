import 'package:flutter/material.dart';
import 'package:job_bit/models/job_model.dart';
import 'package:job_bit/screens/auth/auth_required_screen.dart';
import 'package:job_bit/services/auth_service.dart';
import 'package:job_bit/services/job_service.dart';
import 'package:job_bit/utils/email_helper.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;
  const JobDetailsScreen({super.key, required this.job});
  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final AuthService _auth = AuthService();
  final JobService _jobService = JobService();

  // Helper: Choose SnackBar color based on error type
  Color _getErrorColor(EmailContactResult result) {
    switch (result) {
      case EmailContactResult.noEmailProvided:
        return Colors.orange; // Warning: no email
      case EmailContactResult.invalidEmailFormat:
        return Colors.orange; // Warning: bad format
      case EmailContactResult.noEmailAppInstalled:
        return Colors.blue; // Info: install app
      case EmailContactResult.unknownError:
      default:
        return Colors.red; // Error: something went wrong
    }
  }

  Future<void> _toggleBookmark() async {
    final wasBookmarked = widget.job.isBookmarked;
    setState(() => widget.job.isBookmarked = !wasBookmarked);
    try {
      if (wasBookmarked) {
        await _jobService.unsaveJob(widget.job.id);
      } else {
        await _jobService.saveJob(widget.job.id);
      }
    } catch (_) {
      if (mounted) setState(() => widget.job.isBookmarked = wasBookmarked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.isAuthenticated) {
      return const AuthRequiredScreen(
        title: 'Sign in required',
        message: 'Sign in to view job details and contact the employer.',
      );
    }

    final cs = Theme.of(context).colorScheme;
    final firstTimeRange = widget.job.schedule.values.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(
              widget.job.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: widget.job.isBookmarked ? cs.primary : cs.outline,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Job summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.job.businessName,
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on, widget.job.location, cs),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.calendar_today,
                      widget.job.workDays.join(', '),
                      cs,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.access_time,
                      '${firstTimeRange.start.format(context)} - ${firstTimeRange.end.format(context)}',
                      cs,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.job.pricePerHour} DA/Hour',
                      style: TextStyle(
                        fontSize: 18,
                        color: cs.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Description
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.job.description,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Requirements


            // Contact button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Call the helper and get specific result
                  final result = await EmailHelper.contactEmployer(
                    email: widget.job.email, // Pass nullable email directly
                    subject: 'Job Inquiry: ${widget.job.title}',
                    body:
                        'Hello,\n\nI am interested in your job posting: ${widget.job.title}.\n\nPlease provide more details.\n\nThank you!',
                  );

                  // Show appropriate message based on result
                  if (result != EmailContactResult.success && mounted) {
                    final message = EmailHelper.getMessage(result);

                    // Choose color based on error type
                    final color = _getErrorColor(result);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: color,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.badge),
                label: const Text('Contact Employer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }
}
