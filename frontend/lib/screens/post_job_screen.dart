import 'package:flutter/material.dart';
import 'package:job_bit/models/job_model.dart';
import 'package:job_bit/models/time_range.dart';
import 'package:job_bit/screens/auth/auth_required_screen.dart';
import 'package:job_bit/services/auth_service.dart';
import 'package:job_bit/services/job_service.dart';
import 'package:job_bit/theme/app_theme.dart';
import 'package:job_bit/widgets/cards/business_info_card.dart';
import 'package:job_bit/widgets/buttons/submit_button.dart';
import 'package:job_bit/widgets/cards/job_info_card.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _titleController = TextEditingController();
  final _descpriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _requirementsController = TextEditingController();

  final List<String> _weekDays = const [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  final Map<String, TimeRange> _selectedSchedule = {};

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _titleController.dispose();
    _descpriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _submit() async {
    final business = _auth.currentBusinessProfile;
    if (business == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in with a business account first.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSchedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day with hours'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final price = int.tryParse(_priceController.text) ?? 0;

    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessId: _auth.currentUserId ?? 'current_user_id',
      businessName: business.businessName,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? 'N/A'
          : _websiteController.text.trim(),
      title: _titleController.text.trim(),
      description: _descpriptionController.text.trim(),
      location: _locationController.text.trim(),
      requirements: _requirementsController.text.trim(),
      schedule: Map<String, TimeRange>.from(_selectedSchedule),
      pricePerHour: price,
    );

    try {
      await JobService().postJob(job);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job posted successfully!')),
    );

    _titleController.clear();
    _descpriptionController.clear();
    _locationController.clear();
    _priceController.clear();
    _requirementsController.clear();
    _emailController.clear();
    _phoneController.clear();
    _websiteController.clear();

    setState(() => _selectedSchedule.clear());
  }

  Future<TimeOfDay?> _showTimePicker(TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  Future<void> _toggleDay(String day) async {
    if (_selectedSchedule.containsKey(day)) {
      setState(() => _selectedSchedule.remove(day));
      return;
    }

    final now = TimeOfDay.now();
    final start = await _showTimePicker(now);
    if (start == null) return;

    final end = await _showTimePicker(start);
    if (end == null) return;

    if (_toMinutes(end) <= _toMinutes(start)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedSchedule[day] = TimeRange(start: start, end: end);
    });
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_auth.currentBusinessProfile == null) {
      return const AuthRequiredScreen(
        title: 'Business account required',
        message: 'Sign in with a business account to post jobs.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingLarge,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: AppTheme.paddingMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell students about your business and the job opportunity',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: BusinessInfoCard(
                  phoneController: _phoneController,
                  emailController: _emailController,
                  websiteController: _websiteController,
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: JobInfoCard(
                  titleController: _titleController,
                  descriptionController: _descpriptionController,
                  locationController: _locationController,
                  priceController: _priceController,
                  requirementsController: _requirementsController,
                  weekDays: _weekDays,
                  selectedSchedule: _selectedSchedule,
                  onDayTap: _toggleDay,
                ),
              ),
              const SizedBox(height: 24),

              SubmitButton(formKey: _formKey, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}