import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../user_model.dart';



class LoginViewModel extends ChangeNotifier {
  final _auth = AuthService();
  bool isLoading = false;
  String? errorMessage;
  String? role;
  UserProfile? studentProfile;
  BusinessProfile? businessProfile;

  Future<bool> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Please fill in all fields";
      notifyListeners();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _auth.signIn(email: email, password: password);
    isLoading = false;
    if (result == "Success") {
      role = _auth.currentRole;
      if (role == 'Student') {
        studentProfile = _auth.getStudentProfile(email);
      } else {
        businessProfile = _auth.getBusinessProfile(email);
      }
      notifyListeners();
      return true;
    } else {
      errorMessage = result;
      notifyListeners();
      return false;
    }
  }
}
