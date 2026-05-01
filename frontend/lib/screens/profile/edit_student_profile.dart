import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'package:job_bit/screens/profile/change_password_screen.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController dobController;

  File? profileImage;
  bool isLoading = false;
  String? errorMessage;
  DateTime? _lastDeleteTap;
  bool _deleteLoading = false; 
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    phoneController = TextEditingController(text: widget.user.phone);
    dobController = TextEditingController(text: widget.user.dob);
    if (widget.user.profileImagePath != null) {
      profileImage = File(widget.user.profileImagePath!);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: cs.primary),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: cs.primary),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _auth.updateStudentProfile(
      email: widget.user.email,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      dob: dobController.text.trim(),
      profileImagePath: profileImage?.path,
    );

    setState(() => isLoading = false);

    if (result == "Success") {
      final updatedUser = UserProfile(
        name: nameController.text.trim(),
        email: widget.user.email,
        phone: phoneController.text.trim(),
        dob: dobController.text.trim(),
        profileImagePath: profileImage?.path,
      );
      if (mounted) Navigator.pop(context, updatedUser);
    } else {
      setState(() => errorMessage = result);
    }
  }
  Future<void> _handleDeleteAccount() async {
    final now = DateTime.now();
    if (_lastDeleteTap == null || now.difference(_lastDeleteTap!).inSeconds >= 3) {
      setState(() => _lastDeleteTap = now);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tap again within 3 seconds to delete your account'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      _deleteLoading = true;
      _lastDeleteTap = null;
    });
    try {
      final token = _auth.token;
      final baseUrl = _getBaseUrl();
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteAccount'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _auth.logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _deleteLoading = false;
          errorMessage = data['message'] ?? 'Failed to delete account';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deleteLoading = false;
        errorMessage = 'Could not connect to server';
      });
    }
  }

  String _getBaseUrl() {
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
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile picture picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: cs.surfaceContainerHighest,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : null,
                        child: profileImage == null
                            ? Icon(
                                Icons.person_outline,
                                size: 60,
                                color: cs.outline,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to change photo',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                if (errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cs.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Phone is required'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: dobController,
                  label: 'Date of Birth',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => dobController.text =
                          "${picked.month}/${picked.day}/${picked.year}");
                    }
                  },
                ),
                                const SizedBox(height: 20),





                // Change Password button - navigates to ChangePasswordScreen


                Card(


                  color: Theme.of(context).colorScheme.primaryContainer,


                  child: ListTile(


                    leading: Icon(


                      Icons.lock_outline,


                      color: Theme.of(context).colorScheme.onPrimaryContainer,


                    ),


                    title: Text(


                      'Change Password',


                      style: Theme.of(context).textTheme.bodyLarge,


                    ),


                    trailing: Icon(


                      Icons.arrow_forward_ios,


                      size: 16,


                      color: Theme.of(context).colorScheme.onPrimaryContainer,


                    ),


                    onTap: () {


                      Navigator.push(


                        context,


                        MaterialPageRoute(


                          builder: (context) => const ChangePasswordScreen(),


                        ),


                      );


                    },


                  ),


                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveChanges,
                    child: isLoading
                        ? CircularProgressIndicator(color: cs.onPrimary)
                    : const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error),
                    ),
                    icon: _deleteLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.error,
                            ),
                          )
                        : const Icon(Icons.delete_forever),
                    label: Text(
                      _lastDeleteTap != null &&
                              DateTime.now().difference(_lastDeleteTap!).inSeconds < 3
                          ? 'Tap again to confirm'
                          : 'Delete Account',
                    ),
                    onPressed: _deleteLoading ? null : _handleDeleteAccount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}