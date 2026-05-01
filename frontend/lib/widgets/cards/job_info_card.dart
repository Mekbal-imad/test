import 'package:flutter/material.dart';
import 'package:job_bit/models/time_range.dart';
import 'package:job_bit/widgets/custom_form_field.dart';
import 'package:job_bit/widgets/schedule_selector.dart';

/// JobInfoCard is a reusable card widget that displays job-related form fields.
/// This card is used in the Post Job screen to collect job details from the employer.
///
/// It includes:
/// - Job title input
/// - Job description input
/// - Location input
/// - Schedule selector (days and time ranges)
/// - Pay per hour input
class JobInfoCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController priceController;
  final TextEditingController requirementsController;
  final List<String> weekDays;
  final Map<String, TimeRange> selectedSchedule;
  final ValueChanged<String> onDayTap;

  const JobInfoCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.priceController,
    required this.requirementsController,
    required this.weekDays,
    required this.selectedSchedule,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define theme lookups
    final cs = Theme.of(context).colorScheme; 
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: cs.surface, 
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant, width: 1), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with icon and title
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant, width: 1), 
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer, 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: cs.primary, 
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Job details", 
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CustomFormField(
              label: 'Job Title *',
              hint: 'Waiter, Developer...',
              controller: titleController,
              icon: Icons.work_outline,
            ),

            CustomFormField(
              label: 'Description',
              hint: 'Describe the job...',
              controller: descriptionController,
              maxLines: 3,
              isRequired: false,
            ),

            CustomFormField(
              label: 'Requirements *',
              hint: 'e.g. Experience, degree, skills...',
              controller: requirementsController,
              maxLines: 3,
            ),

            CustomFormField(
              label: 'Location *',
              hint: 'Algiers, Blida...',
              controller: locationController,
              icon: Icons.location_on,
            ),

            const SizedBox(height: 12),

            //! Schedule selector widget for choosing work days and time ranges
            ScheduleSelector(
              weekDays: weekDays,
              selectedSchedule: selectedSchedule,
              onDayTap: onDayTap,
            ),

            const SizedBox(height: 12),

            // Pay per hour input field (required, numeric only)
            CustomFormField(
              label: "Pay per Hour (DZD) *",
              hint: '150',
              controller: priceController,
              keyboardType: TextInputType.number, // keybord only numbers
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null) return 'Enter a valid number';
                if (parsed <= 0) return 'Enter amount greater than 0';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}