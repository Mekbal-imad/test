import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:job_bit/models/job_model.dart';

class JobService {
  JobService._internal();
  factory JobService() => instance;
  static final JobService instance = JobService._internal();

  /// Gets the current auth token from AuthService automatically.
  String? get _currentToken => _storedToken;
  String? _storedToken;
  void setToken(String? token) => _storedToken = token;

  static String get _baseUrl {
    if (kIsWeb) return 'https://projects4-om6u.onrender.com/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'https://projects4-om6u.onrender.com/api';
      case TargetPlatform.iOS:
        return 'https://projects4-om6u.onrender.com/api';
      default:
        return 'https://projects4-om6u.onrender.com/api';
    }
  }

  final List<Job> _sessionPostedJobs = [];

  List<Job> get sessionPostedJobs => List.unmodifiable(_sessionPostedJobs);
  
  Future<Set<String>> fetchSavedJobIds({String? authToken}) async {
    final saved = await fetchSavedJobs(authToken: authToken);
    return saved.map((j) => j.id).toSet();
  }
// NEW:
  Future<Job> postJob(Job job, {String? authToken}) async {
    final token = authToken ?? _currentToken;
    final response = await http.post(
      Uri.parse('$_baseUrl/postJob'),
      headers: _headers(token),
      body: jsonEncode(_buildPostBody(job)),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final realId = body['_id']?.toString() ?? job.id;
      final savedJob = Job(
        id: realId,
        businessId: job.businessId,
        businessName: job.businessName,
        phone: job.phone,
        email: job.email,
        website: job.website,
        title: job.title,
        description: job.description,
        requirements: job.requirements,
        location: job.location,
        schedule: job.schedule,
        pricePerHour: job.pricePerHour,
        isBookmarked: job.isBookmarked,
      );
      _sessionPostedJobs.removeWhere((existing) => existing.id == job.id);
      _sessionPostedJobs.insert(0, savedJob);
      return savedJob;
    }

    throw Exception(_extractError(response));
  }

 Future<List<Job>> fetchPostedJobs({
    String? businessName,
    String? authToken,
  }) async {
    final token = authToken ?? _currentToken;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/jobs'),
        headers: _headers(token),
      );

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rawJobs = decoded is Map<String, dynamic>
          ? (decoded['jobs'] as List<dynamic>? ?? <dynamic>[])
          : (decoded as List<dynamic>);

      final jobs = rawJobs
          .whereType<Map>()
          .map((job) => Job.fromJson(Map<String, dynamic>.from(job)))
          .where((job) {
            final filter = businessName?.trim().toLowerCase();
            if (filter == null || filter.isEmpty) return true;
            return job.businessName.trim().toLowerCase() == filter;
          })
          .toList();

      final merged = <String, Job>{
        for (final job in jobs) job.id: job,
      };

      // Remove session jobs that already exist in backend (matched by id or title+business)
      _sessionPostedJobs.removeWhere((sJob) =>
        merged.containsKey(sJob.id) ||
        jobs.any((bJob) =>
          bJob.title == sJob.title &&
          bJob.businessName == sJob.businessName
        )
      );

      // Add remaining session jobs (just posted, not yet in backend)
      for (final job in _sessionPostedJobs) {
        merged[job.id] = job;
      }

      return merged.values.toList();
    } catch (_) {
      if (_sessionPostedJobs.isNotEmpty) {
        final filter = businessName?.trim().toLowerCase();
        if (filter == null || filter.isEmpty) {
          return List<Job>.from(_sessionPostedJobs);
        }

        return _sessionPostedJobs
            .where((job) => job.businessName.trim().toLowerCase() == filter)
            .toList();
      }

      rethrow;
    }
  }

  Future<void> updateJob(String jobId, Job job, {String? authToken}) async {
    final token = authToken ?? _currentToken;
    final response = await http.put(
      Uri.parse('$_baseUrl/updateJob/$jobId'),
      headers: _headers(token),
      body: jsonEncode(_buildPostBody(job)),
    );

    if (response.statusCode == 200) {
      final index = _sessionPostedJobs.indexWhere((j) => j.id == jobId);
      if (index != -1) _sessionPostedJobs[index] = job;
      return;
    }

    throw Exception(_extractError(response));
  }

  Future<void> deleteJob(String jobId, {String? authToken}) async {
    final token = authToken ?? _currentToken;
    final response = await http.delete(
      Uri.parse('$_baseUrl/delJob/$jobId'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      _sessionPostedJobs.removeWhere((job) => job.id == jobId);
      return;
    }

    throw Exception(_extractError(response));
  }

    /// Fetches jobs posted by the current user via /userJobs.
  Future<List<Job>> fetchMyPostedJobs({String? authToken}) async {
    final token = authToken ?? _currentToken;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/userJobs'),
        headers: _headers(token),
      );

      if (response.statusCode == 404) return [];

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rawJobs =
          decoded is List<dynamic> ? decoded : <dynamic>[];

      final jobs = rawJobs
          .whereType<Map>()
          .map((job) => Job.fromJson(Map<String, dynamic>.from(job)))
          .toList();

      _sessionPostedJobs.clear();
      _sessionPostedJobs.addAll(jobs);
      return jobs;
    } catch (_) {
      if (_sessionPostedJobs.isNotEmpty) return List<Job>.from(_sessionPostedJobs);
      rethrow;
    }
  }
  Map<String, dynamic> _buildPostBody(Job job) {
    final days = job.schedule.keys.toList();
    final firstRange = job.schedule.values.first;

    return {
      'jobTitle': job.title,
      'entrepriseName': job.businessName,
      'days': days,
      'time': {
        'start': _formatTimeOfDay(firstRange.start),
        'end': _formatTimeOfDay(firstRange.end),
      },
      'location': _buildLocation(job.location),
      'payment': job.pricePerHour.toString(),
      'description': job.description,
      'requirements': job.requirements.contains(',')
          ? job.requirements.split(',').map((r) => r.trim()).where((r) => r.isNotEmpty).toList()
          : [job.requirements],
      'contactNB': [job.phone],
      'contactMail': [job.email ?? ''],
      'website': (job.website != null && job.website!.isNotEmpty) ? job.website! : 'N/A',
    };
  }

  Map<String, dynamic> _buildLocation(String location) {
    return {
      'type': 'Point',
      'coordinates': <double>[0, 0],
      'address': {'street': '', 'city': location, 'wilaya': null},
    };
  }

  Map<String, String> _headers(String? authToken) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null && authToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${authToken.trim()}';
    }
    return headers;
  }

  String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return (decoded['error'] ?? decoded['message'] ?? response.body)
            .toString();
      }
    } catch (_) {
      // Use the raw response body below.
    }

    return response.body.isEmpty
        ? 'Request failed with status ${response.statusCode}'
        : response.body;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> saveJob(String jobId, {String? authToken}) async {
    final token = authToken ?? _currentToken;
    final response = await http.put(
      Uri.parse('$_baseUrl/save/$jobId'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  Future<void> unsaveJob(String jobId, {String? authToken}) async {
    final token = authToken ?? _currentToken;
    final response = await http.delete(
      Uri.parse('$_baseUrl/unsave/$jobId'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  Future<List<Job>> fetchSavedJobs({String? authToken}) async {
    final token = authToken ?? _currentToken;
    final response = await http.get(
      Uri.parse('$_baseUrl/savedJobs'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
    final decoded = jsonDecode(response.body);
    final List<dynamic> rawJobs = decoded is List<dynamic>
        ? decoded
        : (decoded['jobs'] as List<dynamic>? ?? <dynamic>[]);
    return rawJobs
        .whereType<Map>()
        .map((job) => Job.fromJson(Map<String, dynamic>.from(job)))
        .toList();
}}