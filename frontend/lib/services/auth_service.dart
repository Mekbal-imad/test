import 'dart:convert';
import 'package:job_bit/services/job_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:job_bit/services/job_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static String get _baseUrl {
    if (kIsWeb) return 'https://test-production-0baa.up.railway.app/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'https://test-production-0baa.up.railway.app/api';
      case TargetPlatform.iOS:
        return 'https://test-production-0baa.up.railway.app/api';
      default:
        return 'https://test-production-0baa.up.railway.app/api';
    }
  }

  String? _token;
  String? _currentEmail;
  String? _currentRole;
  String? _currentUserId;
  String? _currentUsername;
  UserProfile? _studentProfile;
  BusinessProfile? _businessProfile;

  bool get isAuthenticated => _token != null;
  String? get currentEmail => _currentEmail;
  String? get currentRole => _currentRole;
  String? get token => _token;
  String? get currentUserId => _currentUserId;
  String? get currentUsername => _currentUsername;
  UserProfile? get currentStudentProfile => _studentProfile;
  BusinessProfile? get currentBusinessProfile => _businessProfile;

  // Frontend uses 'Student'/'Business', backend uses 'user'/'entreprise'
  static String _toBackendRole(String frontendRole) {
    return frontendRole == 'Business' ? 'entreprise' : 'user';
  }

  static String _toFrontendRole(String backendRole) {
    return backendRole == 'entreprise' ? 'Business' : 'Student';
  }

  void logout() {
    _token = null;
    JobService.instance.setToken(null);
    _currentEmail = null;
    _currentRole = null;
    _currentUserId = null;
    _currentUsername = null;
    _studentProfile = null;
    _businessProfile = null;
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
    try {
      final backendRole = _toBackendRole(role);
      final username = (role == 'Business')
          ? (businessName ?? email.split('@').first)
          : (name ?? email.split('@').first);

      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'role': backendRole,
        'username': username,
      };

      if (backendRole == 'entreprise' && businessField != null) {
        body['field'] = businessField;
        if (location != null && location.isNotEmpty) body['location'] = location;
        if (businessPhones != null && businessPhones.isNotEmpty) body['number'] = businessPhones;
      }

      if (backendRole == 'user') {
        if (phone != null && phone.isNotEmpty) body['number'] = phone;
        if (dob != null && dob.isNotEmpty) body['dob'] = dob;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        JobService.instance.setToken(_token);
        _currentEmail = email;
        _currentRole = role;
        _currentUsername = username;
        _currentUserId = data['user']?['id']?.toString();

        if (role == 'Student') {
          _studentProfile = UserProfile(
            name: name ?? '',
            email: email,
            phone: phone ?? '',
            dob: dob ?? '',
            profileImagePath: profileImagePath,
          );
          _businessProfile = null;
        } else {
          _businessProfile = BusinessProfile(
            businessName: businessName ?? '',
            email: email,
            location: location ?? '',
            businessField: businessField,
            profileImagePath: profileImagePath,
          );
          _studentProfile = null;
        }
        return "Success";
      } else {
        return "Error: ${data['error'] ?? data['message'] ?? 'Registration failed'}";
      }
    } catch (e) {
      return "Error: Could not connect to server. $e";
    }
  }

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
    _token = data['token'];
    JobService.instance.setToken(_token);
    _currentEmail = email;
    _currentUserId = data['user']['id'];
    _currentUsername = data['user']['username'];
    _currentRole = _toFrontendRole(data['user']['role']);

    final userData = data['user'];

    if (_currentRole == 'Student') {
        _studentProfile = UserProfile(
            name: userData['username'] ?? '',
            email: email,
            phone: (userData['number'] is List && userData['number'].isNotEmpty)
                ? userData['number'][0]
                : '',
            dob: userData['dob'] ?? '',
            profileImagePath: userData['pdpUrl'],
        );
        _businessProfile = null;
    } else {
        _businessProfile = BusinessProfile(
            businessName: userData['username'] ?? '',
            email: email,
            location: userData['location'] ?? '',
            businessField: userData['field'],
            profileImagePath: userData['pdpUrl'],
        );
        _studentProfile = null;
    }
    return "Success";
      } else {
        return "Error: ${data['message'] ?? data['error'] ?? 'Login failed'}";
      }
    } catch (e) {
      return "Error: Could not connect to server. $e";
    }
  }

  String? getRole(String email) {
    if (_currentEmail == email) return _currentRole;
    return null;
  }

  UserProfile? getStudentProfile(String email) {
    if (_currentEmail == email && _currentRole == 'Student') return _studentProfile;
    return null;
  }

  BusinessProfile? getBusinessProfile(String email) {
    if (_currentEmail == email && _currentRole == 'Business') return _businessProfile;
    return null;
  }

  Future<String> updateStudentProfile({
  required String email,
  required String name,
  required String phone,
  required String dob,
  String? profileImagePath,
}) async {
  if (_token == null) return "Error: Not authenticated.";
  try {
    final response = await http.put(
      Uri.parse('$_baseUrl/updateProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'username': name,
        'number': [phone],
        'dob': dob,
      }),
    );
    if (response.statusCode == 200) {
      _studentProfile = UserProfile(
        name: name, email: email, phone: phone, dob: dob,
        profileImagePath: profileImagePath ?? _studentProfile?.profileImagePath,
      );
      _currentUsername = name;
      return "Success";
    }
    final data = jsonDecode(response.body);
    return "Error: ${data['message'] ?? 'Update failed'}";
  } catch (e) {
    return "Error: Could not connect to server.";
  }
}

Future<String> updateBusinessProfile({
  required String email,
  required String businessName,
  required String location,
  String? profileImagePath,
}) async {
  if (_token == null) return "Error: Not authenticated.";
  try {
    final response = await http.put(
      Uri.parse('$_baseUrl/updateProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'username': businessName,
        'location': location,
      }),
    );
    if (response.statusCode == 200) {
      _businessProfile = BusinessProfile(
        businessName: businessName, email: email, location: location,
        businessField: _businessProfile?.businessField,
        profileImagePath: profileImagePath ?? _businessProfile?.profileImagePath,
      );
      _currentUsername = businessName;
      return "Success";
    }
    final data = jsonDecode(response.body);
    return "Error: ${data['message'] ?? 'Update failed'}";
  } catch (e) {
    return "Error: Could not connect to server.";
  }
}

  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_token == null) return "Error: Not authenticated.";
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/changePassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return "Success";
      return "Error: ${data['message'] ?? 'Password change failed'}";
    } catch (e) {
      return "Error: Could not connect to server. $e";
    }
  }
String _lastOtp = '';

Future<String> sendPasswordResetOtp({required String email}) async {
  try {
    final response = await http.put(
      Uri.parse('$_baseUrl/sendChangePassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) return "Success";
    final data = jsonDecode(response.body);
    return data['message'] ?? 'Failed to send code';
  } catch (e) {
    return 'Network error';
  }
}

Future<String> verifyOtp({required String email, required String otp}) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/verifyCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': otp}),
    );
    if (response.statusCode == 200) {
      _lastOtp = otp;
      return "Success";
    }
    final data = jsonDecode(response.body);
    return data['message'] ?? 'Invalid code';
  } catch (e) {
    return 'Network error';
  }
}

Future<String> resetPassword({required String email, required String newPassword}) async {
  try {
    final response = await http.put(
      Uri.parse('$_baseUrl/confirmNewPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': _lastOtp,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode == 200) {
      _lastOtp = '';
      return "Success";
    }
    final data = jsonDecode(response.body);
    return data['message'] ?? 'Failed to reset password';
  } catch (e) {
    return 'Network error';
  }
}
}