import 'package:flutter/material.dart';

import '../../services/auth_service.dart';


class ForgotPasswordViewModel extends ChangeNotifier {
  final _auth = AuthService();

  bool isLoading = false;
  String? errorMessage;

  /// Returns true on success, false on error (errorMessage will be set).
  Future<bool> sendOtp(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _auth.sendPasswordResetOtp(email: email);

    isLoading = false;
    if (result != "Success") {
      errorMessage = result;
    }
    notifyListeners();

    return result == "Success";
  }
}
