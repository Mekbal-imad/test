import 'package:flutter/widgets.dart';
import 'package:job_bit/models/job_model.dart';

class JobProvider with ChangeNotifier {
  //! private list of jobs
  final List<Job> _jobs = [];

  //!public getter to access jobs
  List<Job> get jobs => _jobs;

  //! function to add job
  void addJob(Job job) {
    _jobs.add(job);
    notifyListeners();
  }

  //! function to remove job
  void removeJob(String id) {
    _jobs.removeWhere((job) => job.id == id);
    notifyListeners();
  }

  //! function clear all jobs
  void clearJobs() {
    _jobs.clear();
    notifyListeners();
  }
}
