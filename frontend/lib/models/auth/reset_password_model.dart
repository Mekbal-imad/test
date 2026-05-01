import 'package:flutter/material.dart';

import '../../services/auth_service.dart';


class ResetPasswordViewModel extends ChangeNotifier {
  final _auth = AuthService();
  final String email;

  ResetPasswordViewModel({required this.email});

  bool isLoading = false;
  String? errorMessage;

  Future<bool> resetPassword(String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _auth.resetPassword(
      email: email,
      newPassword: newPassword,
    );

    isLoading = false;
    if (result != "Success") {
      errorMessage = result;
    }
    notifyListeners();

    return result == "Success";
  }
}
