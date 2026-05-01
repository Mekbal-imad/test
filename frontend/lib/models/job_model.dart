import 'package:flutter/material.dart';
import 'package:job_bit/models/time_range.dart';

class Job {
  bool isBookmarked = false;
  final String id;
  final String businessId;
  final String businessName;
  final String phone;
  final String? email;
  final String? website;
  final String title;
  final String description;
  final String location;
  final String requirements;
  final Map<String, TimeRange> schedule;
  final int pricePerHour;

  Job({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.phone,
    this.isBookmarked = false,
    this.email,
    this.website,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.schedule,
    required this.pricePerHour,
  });
  // helper method to calculate total hours
  int get totalHours {
    int totalMinutes = 0;

    for (var range in schedule.values) {
      int start = _toMinutes(range.start);
      int end = _toMinutes(range.end);

      if (end > start) {
        totalMinutes += end - start;
      }
    }

    return totalMinutes ~/ 60;
  }

  // helper method to calculate weekly pay based on totalHours
  int get weeklyPay {
    return totalHours * pricePerHour;
  }

  List<String> get workDays => schedule.keys.toList();

  //! Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'isBookmarked': isBookmarked,
      'id': id,
      'businessId': businessId,
      'businessName': businessName,
      'phone': phone,
      'email': email,
      'website': website,
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
      'schedule': schedule.map((day, range) => MapEntry(day, range.toJson())),
      'pricePerHour': pricePerHour,
    };
  }

  //! Create a Job from JSON
  factory Job.fromJson(Map<String, dynamic> json) {
    final scheduleJson = json['schedule'];
    final locationJson = json['location'];
    Map<String, TimeRange> schedule = {};

    if (scheduleJson is Map<String, dynamic>) {
      schedule = scheduleJson.map(
        (day, rangeJson) => MapEntry(
          day,
          TimeRange.fromJson(rangeJson as Map<String, dynamic>),
        ),
      );
    } else if (json['days'] != null && json['time'] != null) {
      final days = List<String>.from(json['days'] ?? []);
      final time = json['time'];

      if (days.isNotEmpty && time is Map<String, dynamic>) {
        final start = _parseTimeOfDay(time['start']);
        final end = _parseTimeOfDay(time['end']);

        if (start != null && end != null) {
          schedule = {
            for (final day in days) day: TimeRange(start: start, end: end),
          };
        }
      }
    } else {
      final workDays = List<String>.from(json['workDays'] ?? []);
      if (workDays.isNotEmpty &&
          json['startHour'] != null &&
          json['endHour'] != null) {
        final startHour = DateTime.parse(json['startHour']);
        final endHour = DateTime.parse(json['endHour']);
        final start = TimeOfDay(hour: startHour.hour, minute: startHour.minute);
        final end = TimeOfDay(hour: endHour.hour, minute: endHour.minute);

        schedule = {
          for (final day in workDays) day: TimeRange(start: start, end: end),
        };
      }
    }

    String parsedLocation = '';
    if (locationJson is Map<String, dynamic>) {
      final address = locationJson['address'];
      if (address is Map<String, dynamic>) {
        parsedLocation = (address['city'] ?? '').toString();
      }
    } else if (locationJson != null) {
      parsedLocation = locationJson.toString();
    }

    return Job(
      isBookmarked: json['isSaved'] ?? json['isBookmarked'] ?? false,
      id: json['_id'], // backend sends _id
      businessId: json['entrepriseID'] ?? '', // backend sends entrepriseID
      businessName:
          json['entrepriseName'] ?? '', // backend sends entrepriseName
      phone:
          (json['contactNB'] as List?)?.first ??
          '', // backend sends contactNB list
      email: (json['contactMail'] as List?)
          ?.first, // backend sends contactMail list
      website: json['website'],
      title: json['jobTitle'], // backend sends jobTitle
      description: json['description'],
      requirements: (json['requirements'] as List?)?.join(', ') ?? '',
      location: parsedLocation, // backend sends nested location
      schedule: schedule,
      pricePerHour:
          int.tryParse(json['payment'].toString()) ??
          0, // backend sends payment as string
    );
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static TimeOfDay? _parseTimeOfDay(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }
}
