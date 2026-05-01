import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {
      'start': {'hour': start.hour, 'minute': start.minute},
      'end': {'hour': end.hour, 'minute': end.minute},
    };
  }

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    final startJson = json['start'] as Map<String, dynamic>;
    final endJson = json['end'] as Map<String, dynamic>;

    return TimeRange(
      start: TimeOfDay(
        hour: startJson['hour'] as int,
        minute: startJson['minute'] as int,
      ),
      end: TimeOfDay(
        hour: endJson['hour'] as int,
        minute: endJson['minute'] as int,
      ),
    );
  }
}
