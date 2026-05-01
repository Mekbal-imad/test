import 'package:flutter/material.dart';
import 'package:job_bit/models/job_model.dart';
import 'package:job_bit/services/job_service.dart';

class JobFeedCard extends StatefulWidget {
  final Job job;
  const JobFeedCard({super.key, required this.job});

  @override
  State<JobFeedCard> createState() => _JobFeedCardState();
}

class _JobFeedCardState extends State<JobFeedCard> {
  final JobService _jobService = JobService();

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
    final cs = Theme.of(context).colorScheme;
    final firstTimeRange = widget.job.schedule.values.isNotEmpty
        ? widget.job.schedule.values.first
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.job.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.job.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: widget.job.isBookmarked ? cs.primary : cs.outline,
                  ),
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
            Text(
              widget.job.businessName,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, widget.job.location, cs),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.calendar_today,
              widget.job.workDays.join(', '),
              cs,
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.access_time,
              firstTimeRange != null
                  ? '${firstTimeRange.start.format(context)} - ${firstTimeRange.end.format(context)}'
                  : 'No time set',
              cs,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.job.pricePerHour} DA/Hour',
              style: TextStyle(
                fontSize: 16,
                color: cs.tertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () {
                  //TODO: navigate to contact screen
                },
                icon: const Icon(Icons.badge, size: 20),
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
