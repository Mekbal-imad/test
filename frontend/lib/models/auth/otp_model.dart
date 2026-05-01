import 'package:flutter/material.dart';

import '../../services/auth_service.dart';


class OtpViewModel extends ChangeNotifier {
  final _auth = AuthService();
  final String email;

  OtpViewModel({required this.email});

  bool isLoading = false;
  String? errorMessage;

  Future<bool> verifyOtp(String otp) async {
    if (otp.length < 4) {
      errorMessage = 'Please enter the 4-digit code';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _auth.verifyOtp(email: email, otp: otp);

    isLoading = false;
    if (result != "Success") {
      errorMessage = result;
    }
    notifyListeners();

    return result == "Success";
  }

  Future<void> resendOtp() async {
    await _auth.sendPasswordResetOtp(email: email);
  }
}
