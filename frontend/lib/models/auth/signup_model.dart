import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../services/auth_service.dart';


class SignUpViewModel extends ChangeNotifier {
  final _auth = AuthService();
  final _picker = ImagePicker();

  // ── State ──────────────────────────────────────────────────────────────────
  String selectedRole = "Student";
  String? selectedBusinessField;
  File? profileImage;
  bool isSavingImage = false;
  bool isLoading = false;
  String? errorMessage;

  final List<String> businessFields = [
    'IT & Technology',
    'Retail & Sales',
    'Food & Hospitality',
    'Marketing & Media',
    'Education & Tutoring',
    'Healthcare',
    'Finance & Accounting',
    'Construction & Trades',
    'Transportation & Logistics',
    'Other',
  ];

  // ── Role & Field ───────────────────────────────────────────────────────────
  void setRole(String role) {
    selectedRole = role;
    profileImage = null;
    selectedBusinessField = null;
    notifyListeners();
  }

  void setBusinessField(String? field) {
    selectedBusinessField = field;
    notifyListeners();
  }

  // ── Image ──────────────────────────────────────────────────────────────────
  void removeImage() {
    profileImage = null;
    notifyListeners();
  }

  Future<String?> pickAndSaveImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked == null) return null;

      isSavingImage = true;
      notifyListeners();

      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imgDir = Directory(p.join(appDir.path, 'profile_images'));
      if (!await imgDir.exists()) await imgDir.create(recursive: true);

      final String ext = p.extension(picked.path).isNotEmpty
          ? p.extension(picked.path)
          : '.jpg';
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}$ext';
      final String savedPath = p.join(imgDir.path, fileName);

      await File(picked.path).copy(savedPath);

      profileImage = File(savedPath);
      isSavingImage = false;
      notifyListeners();
      return null; // no error
    } catch (e) {
      isSavingImage = false;
      notifyListeners();
      return 'Could not load image: $e';
    }
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
    String? dob,
    String? businessName,
    String? location,
    List<String>? businessPhones,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final String? imagePath = profileImage?.path;
    String result;

    if (selectedRole == 'Student') {
      result = await _auth.signUp(
        role: 'Student',
        email: email,
        password: password,
        profileImagePath: imagePath,
        name: fullName,
        phone: phone,
        dob: dob,
      );
    } else {
      result = await _auth.signUp(
        role: 'Business',
        email: email,
        password: password,
        profileImagePath: imagePath,
        businessName: businessName,
        location: location,
        businessField: selectedBusinessField,
        businessPhones: businessPhones,
      );
    }

    isLoading = false;
    if (result != "Success") {
      errorMessage = result;
    }
    notifyListeners();

    return result == "Success";
  }

  /// Validates business-specific rule not covered by form validators
  bool get isBusinessFieldValid =>
      selectedRole != 'Business' || selectedBusinessField != null;
}
