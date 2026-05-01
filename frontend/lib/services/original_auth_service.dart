//this is the original authservice
import 'dart:async';
import 'dart:math';
import '../models/user_model.dart';

class _OtpRecord {
  final String otp;
  final DateTime expiresAt;
  _OtpRecord(this.otp)
    : expiresAt = DateTime.now().add(const Duration(minutes: 10));
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class _User {
  final String email;
  String password;
  final String role;
  String? profileImagePath;
  String? name;
  String? phone;
  String? dob;
  String? businessName;
  String? location;
  final String? businessField;
  List<String>? businessPhones;

  _User({
    required this.email,
    required this.password,
    required this.role,
    this.profileImagePath,
    this.name,
    this.phone,
    this.dob,
    this.businessName,
    this.location,
    this.businessField,
    this.businessPhones,
  });
}

class AuthService {
  static final List<_User> _db = [];
  static final Map<String, _OtpRecord> _otpStore = {};
  static String? _currentEmail;
  static String? _currentRole;

  bool get isAuthenticated => _currentEmail != null;
  String? get currentEmail => _currentEmail;
  String? get currentRole => _currentRole;

  UserProfile? get currentStudentProfile =>
      _currentEmail == null ? null : getStudentProfile(_currentEmail!);

  BusinessProfile? get currentBusinessProfile =>
      _currentEmail == null ? null : getBusinessProfile(_currentEmail!);

  void logout() {
    _currentEmail = null;
    _currentRole = null;
  }

  void _setCurrentSession(_User user) {
    _currentEmail = user.email;
    _currentRole = user.role;
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String role,
    String? profileImagePath,
    String? name,
    String? phone,
    String? dob,
    String? businessName,
    String? location,
    String? businessField,
    List<String>? businessPhones,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_db.any((u) => u.email == email)) {
      return "Error: Email already registered.";
    }
    _db.add(
      _User(
        email: email,
        password: password,
        role: role,
        profileImagePath: profileImagePath,
        name: name,
        phone: phone,
        dob: dob,
        businessName: businessName,
        location: location,
        businessField: businessField,
        businessPhones: businessPhones,
      ),
    );
    _setCurrentSession(_db.last);
    return "Success";
  }

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    for (var u in _db) {
      if (u.email == email && u.password == password) {
        _setCurrentSession(u);
        return "Success";
      }
    }
    return "Error: Invalid email or password.";
  }

  String? getRole(String email) {
    try {
      return _db.firstWhere((u) => u.email == email).role;
    } catch (_) {
      return null;
    }
  }

  UserProfile? getStudentProfile(String email) {
    try {
      final u = _db.firstWhere((u) => u.email == email && u.role == 'Student');
      return UserProfile(
        name: u.name ?? '',
        email: u.email,
        phone: u.phone ?? '',
        dob: u.dob ?? '',
        profileImagePath: u.profileImagePath,
      );
    } catch (_) {
      return null;
    }
  }

  BusinessProfile? getBusinessProfile(String email) {
    try {
      final u = _db.firstWhere((u) => u.email == email && u.role == 'Business');
      return BusinessProfile(
        businessName: u.businessName ?? '',
        email: u.email,
        location: u.location ?? '',
        businessField: u.businessField,
        profileImagePath: u.profileImagePath,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> updateStudentProfile({
    required String email,
    required String name,
    required String phone,
    required String dob,
    String? profileImagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var u in _db) {
      if (u.email == email) {
        u.name = name;
        u.phone = phone;
        u.dob = dob;
        if (profileImagePath != null) u.profileImagePath = profileImagePath;
        if (_currentEmail == email) {
          _setCurrentSession(u);
        }
        return "Success";
      }
    }
    return "Error: User not found.";
  }

  Future<String> updateBusinessProfile({
    required String email,
    required String businessName,
    required String location,
    String? profileImagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var u in _db) {
      if (u.email == email) {
        u.businessName = businessName;
        u.location = location;
        if (profileImagePath != null) u.profileImagePath = profileImagePath;
        if (_currentEmail == email) {
          _setCurrentSession(u);
        }
        return "Success";
      }
    }
    return "Error: User not found.";
  }

  Future<String> sendPasswordResetOtp({required String email}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!_db.any((u) => u.email == email)) {
      return "Error: No account found with this email.";
    }
    final otp = (1000 + Random().nextInt(9000)).toString();
    _otpStore[email] = _OtpRecord(otp);
    print("OTP for $email → $otp");
    return "Success";
  }

  Future<String> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final r = _otpStore[email];
    if (r == null) return "Error: No OTP requested for this email.";
    if (r.isExpired) {
      _otpStore.remove(email);
      return "Error: OTP expired.";
    }
    if (r.otp != otp) return "Error: Incorrect OTP.";
    return "Success";
  }

  Future<String> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final r = _otpStore[email];
    if (r == null || r.isExpired) return "Error: Session expired.";
    for (var u in _db) {
      if (u.email == email) {
        u.password = newPassword;
        _otpStore.remove(email);
        return "Success";
      }
    }
    return "Error: User not found.";
  }
}
