import 'package:flutter/material.dart';
import 'package:job_bit/theme/app_theme.dart';

class FilterJobsScreen extends StatefulWidget {
  const FilterJobsScreen({super.key});

  @override
  State<FilterJobsScreen> createState() => _FilterJobsScreenState();
}

class _FilterJobsScreenState extends State<FilterJobsScreen> {
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> selectedDays = {};
  final Set<String> selectedTimes = {};

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  final List<String> timeSlots = [
    'Morning (9 AM - 12 PM)',
    'Afternoon (1 PM - 5 PM)',
    'Evening (6 PM - 10 PM)',
    'Night (11 PM - 3 AM)',
    'Flexible (Any time)',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Jobs'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              selectedDays.clear();
              selectedTimes.clear();
              _locationController.clear();
              _minController.clear();
              _maxController.clear();
            }),
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.location_on_outlined, 'Location'),
                  _buildSectionCard(
                    child: TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'Enter location',
                      ),
                    ),
                  ),

                  _buildSectionHeader(
                    Icons.calendar_today_outlined,
                    'Available Days',
                  ),
                  _buildSectionCard(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          days.map((day) => _buildDayChip(day)).toList(),
                    ),
                  ),

                  _buildSectionHeader(Icons.access_time, 'Time Preference'),
                  _buildSectionCard(
                    child: Column(
                      children: timeSlots
                          .map((time) => _buildTimeOption(time))
                          .toList(),
                    ),
                  ),

                  _buildSectionHeader(Icons.attach_money, 'Hourly Rate'),
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child:
                                  _buildPriceField('Min', _minController),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'to',
                                style: TextStyle(color: cs.outline),
                              ),
                            ),
                            Expanded(
                              child:
                                  _buildPriceField('Max', _maxController),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Price per hour in DZD',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(color: cs.outlineVariant),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, <String, dynamic>{
                  'location': _locationController.text.trim(),
                  'days': Set<String>.from(selectedDays),
                  'times': Set<String>.from(selectedTimes),
                  'minPrice': int.tryParse(_minController.text),
                  'maxPrice': int.tryParse(_maxController.text),
                }),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _buildDayChip(String label) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = selectedDays.contains(label);
    return GestureDetector(
      onTap: () => setState(
        () => isSelected
            ? selectedDays.remove(label)
            : selectedDays.add(label),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? cs.onPrimary : cs.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(String label) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = selectedTimes.contains(label);

    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          selectedTimes.remove(label);
        } else {
          selectedTimes.add(label);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primaryContainer.withValues(alpha: 0.4)
              : cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: hint),
    );
  }
}