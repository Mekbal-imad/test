import 'package:flutter/material.dart';
import 'package:job_bit/models/job_model.dart';
import 'package:job_bit/widgets/cards/job_feed_card.dart';
import 'package:job_bit/screens/filter_job.dart';
import 'package:job_bit/screens/job_details_screen.dart';
import 'package:job_bit/services/auth_service.dart';
import 'package:job_bit/services/job_service.dart';
import 'package:job_bit/widgets/emptyScreens/empty_jobs_feed.dart';
import 'package:job_bit/theme/app_theme.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final AuthService _auth = AuthService();
  final JobService _jobService = JobService();
  List<Job> _jobs = [];
  List<Job> _allJobs = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  Map<String, dynamic>? _activeFilters;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

Future<void> _loadJobs() async {
  try {
    final jobs = await _jobService.fetchPostedJobs();
    if (!mounted) return;
    setState(() {
      _allJobs = jobs;
      _jobs = _applyLocalFilters(jobs);
      _isLoading = false;
      _errorMessage = null;
    });
  } catch (error) {
    if (!mounted) return;
    setState(() {
      _allJobs = [];
      _jobs = [];
      _isLoading = false;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    });
  }
}

  List<Job> _applyLocalFilters(List<Job> jobs) {
    var filtered = jobs;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((j) =>
        j.title.toLowerCase().contains(q) ||
        j.businessName.toLowerCase().contains(q) ||
        j.location.toLowerCase().contains(q)
      ).toList();
    }

    if (_activeFilters != null) {
      final f = _activeFilters!;

      final loc = (f['location'] as String?) ?? '';
      if (loc.isNotEmpty) {
        final locLower = loc.toLowerCase();
        filtered = filtered.where((j) =>
          j.location.toLowerCase().contains(locLower)
        ).toList();
      }

      final days = (f['days'] as Set<String>?) ?? <String>{};
      if (days.isNotEmpty) {
        filtered = filtered.where((j) =>
          j.workDays.any((d) => days.contains(d))
        ).toList();
      }

      final times = (f['times'] as Set<String>?) ?? <String>{};
      if (times.isNotEmpty && !times.contains('Flexible (Any time)')) {
        filtered = filtered.where((j) {
          return j.schedule.values.any((range) {
            final startMinutes = range.start.hour * 60 + range.start.minute;
            return times.any((slot) {
              if (slot.startsWith('Morning'))   return startMinutes >= 9*60  && startMinutes < 12*60;
              if (slot.startsWith('Afternoon')) return startMinutes >= 13*60 && startMinutes < 17*60;
              if (slot.startsWith('Evening'))   return startMinutes >= 18*60 && startMinutes < 22*60;
              if (slot.startsWith('Night'))     return startMinutes >= 23*60 || startMinutes < 3*60;
              return false;
            });
          });
        }).toList();
      }

      final minPrice = f['minPrice'] as int?;
      final maxPrice = f['maxPrice'] as int?;
      if (minPrice != null) {
        filtered = filtered.where((j) => j.pricePerHour >= minPrice).toList();
      }
      if (maxPrice != null) {
        filtered = filtered.where((j) => j.pricePerHour <= maxPrice).toList();
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Perfect Job'),
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: SearchBar(
                    leading: Icon(Icons.search, color: cs.outline),
                    hintText: "Search jobs, companies...",
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                        _jobs = _applyLocalFilters(_allJobs);
                      });
                    },
                    backgroundColor: WidgetStateProperty.all(
                      cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                    hintStyle: WidgetStatePropertyAll(
                      TextStyle(color: cs.outline),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                        side: BorderSide(color: cs.outlineVariant, width: 1),
                      ),
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ),
                const SizedBox(width: 12),

                // Filter button
                Container(
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FilterJobsScreen(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _activeFilters = result;
                          _jobs = _applyLocalFilters(_allJobs);
                        });
                      }
                    },
                    icon: Icon(Icons.tune, color: cs.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 56, color: cs.outline),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.outline),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadJobs,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _jobs.isEmpty
                  ? const EmptyJobsFeed()
                  : ListView.builder(
                      itemCount: _jobs.length,
                      itemBuilder: (context, index) {
                        final job = _jobs[index];
                        return GestureDetector(
                          onTap: () async {
                            if (!_auth.isAuthenticated) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Sign in to view job details.'),
                                ),
                              );
                              Navigator.pushNamed(context, '/login');
                              return;
                            }
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailsScreen(job: job),
                              ),
                            );
                            setState(() {});
                          },
                          child: JobFeedCard(job: job),
                        );
                      },
                    ),
    );
  }
}