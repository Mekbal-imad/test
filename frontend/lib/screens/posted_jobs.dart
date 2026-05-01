import 'package:flutter/material.dart';
import 'package:job_bit/models/job_model.dart';
import 'package:job_bit/models/time_range.dart';
import 'package:job_bit/services/auth_service.dart';
import 'package:job_bit/services/job_service.dart';
import 'package:job_bit/widgets/cards/job_offer_card.dart';
import 'package:job_bit/widgets/cards/business_info_card.dart';
import 'package:job_bit/widgets/cards/job_info_card.dart';
import 'package:job_bit/widgets/buttons/submit_button.dart';
import 'package:job_bit/widgets/emptyScreens/empty_posted_jobs.dart';
import 'package:job_bit/theme/app_theme.dart';
 
/// PostedJobs screen displays the current business job posts.
class PostedJobs extends StatefulWidget {
  const PostedJobs({super.key});
 
  @override
  State<PostedJobs> createState() => _PostedJobsState();
}
 
class _PostedJobsState extends State<PostedJobs> {
  final JobService _jobService = JobService();
  final AuthService _auth = AuthService();
  List<Job> _jobs = [];
  bool _isLoading = true;
 
  @override
  void initState() {
    super.initState();
    _loadMyJobs();
  }
 
  Future<void> _loadMyJobs() async {
    setState(() => _isLoading = true);
 
    // Use the actual business name from the current session
    final businessName = _auth.currentBusinessProfile?.businessName;
 
    try {
      final jobs = await _jobService.fetchPostedJobs(
        businessName: businessName,
      );
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _jobs = const [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
 
  Future<void> _deleteJob(Job job) async {
    try {
      await _jobService.deleteJob(job.id);
      if (!mounted) return;
      await _loadMyJobs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Job Posts'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _jobs.isEmpty
              ? const EmptyPostedJobs()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final job = _jobs[index];
                    return JobOfferCard(
                      title: job.title,
                      businessName: job.businessName,
                      location: job.location,
                      schedule: job.schedule,
                      price: job.pricePerHour,
                      onModify: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _EditJobScreen(job: job),
                          ),
                        );
                        await _loadMyJobs();
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete Job'),
                              content: const Text(
                                'Are you sure you want to delete this job posting?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: cs.error),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm != true) return;
                        await _deleteJob(job);
                      },
                    );
                  },
                ),
    );
  }
}
// ─── Edit Job Screen ───────────────────────────────────────────────────────
 
class _EditJobScreen extends StatefulWidget {
  final Job job;
  const _EditJobScreen({required this.job});
 
  @override
  State<_EditJobScreen> createState() => _EditJobScreenState();
}
 
class _EditJobScreenState extends State<_EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();
 
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _requirementsController;
 
  final List<String> _weekDays = const [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  late Map<String, TimeRange> _selectedSchedule;
 
  @override
  void initState() {
    super.initState();
    final j = widget.job;
    _phoneController = TextEditingController(text: j.phone);
    _emailController = TextEditingController(text: j.email ?? '');
    _websiteController = TextEditingController(text: j.website ?? '');
    _titleController = TextEditingController(text: j.title);
    _descriptionController = TextEditingController(text: j.description);
    _locationController = TextEditingController(text: j.location);
    _priceController = TextEditingController(text: j.pricePerHour.toString());
    _requirementsController = TextEditingController(text: j.requirements);
    _selectedSchedule = Map<String, TimeRange>.from(j.schedule);
  }
 
  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }
 
  Future<TimeOfDay?> _showTimePicker(TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
 
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
 
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
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    setState(() => _selectedSchedule[day] = TimeRange(start: start, end: end));
  }
 
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day with hours')),
      );
      return;
    }
 
    final updated = Job(
      id: widget.job.id,
      businessId: widget.job.businessId,
      businessName: widget.job.businessName,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? 'N/A' : _websiteController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      requirements: _requirementsController.text.trim(),
      schedule: Map<String, TimeRange>.from(_selectedSchedule),
      pricePerHour: int.tryParse(_priceController.text) ?? 0,
    );
 
    try {
      await _jobService.updateJob(widget.job.id, updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job updated successfully!')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: SingleChildScrollView(
        padding: AppTheme.paddingLarge,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  descriptionController: _descriptionController,
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