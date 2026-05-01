import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/auth/signup_model.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _vm = SignUpViewModel();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _locationController = TextEditingController();
  final List<TextEditingController> _businessPhoneControllers = [
    TextEditingController(),
  ];

  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    for (var c in _businessPhoneControllers) {
      c.dispose();
    }

    _animController.dispose();

    super.dispose();
  }

  // ── Image Source Sheet ──
  void _showImageSourceSheet() {
    final cs = Theme.of(context).colorScheme;
    final bool isBusiness = _vm.selectedRole == 'Business';

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isBusiness ? "Upload Business Logo" : "Upload Profile Photo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isBusiness
                      ? "Choose an image for your business logo"
                      : "Choose a photo that represents you",
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sourceOption(
                icon: Icons.camera_alt_outlined,
                label: "Take a photo",
                subtitle: "Open your camera",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _sourceOption(
                icon: Icons.photo_library_outlined,
                label: "Choose from gallery",
                subtitle: "Pick from your photo library",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_vm.profileImage != null) ...[
                const SizedBox(height: 10),
                _sourceOption(
                  icon: Icons.delete_outline,
                  label: "Remove photo",
                  subtitle: "Go back to default avatar",
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _vm.removeImage();
                    setState(() {});
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    final error = await _vm.pickAndSaveImage(source);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
    setState(() {});
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = isDestructive ? cs.error : cs.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.outline),
          ],
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_vm.isBusinessFieldValid) {
      setState(() {});
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating Account...'),
        duration: Duration(seconds: 1),
      ),
    );

    final phones = _businessPhoneControllers
        .map((c) => c.text)
        .where((t) => t.isNotEmpty)
        .toList();

    final success = await _vm.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      dob: _dobController.text,
      businessName: _businessNameController.text,
      location: _locationController.text,
      businessPhones: phones,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          content: const Text('Account Created! Welcome!'),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(_vm.errorMessage ?? 'Unknown error'),
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isBusiness = _vm.selectedRole == 'Business';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient Header ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 28,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary,
                    cs.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Back button row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBusiness ? Icons.business_rounded : Icons.school_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isBusiness ? 'Register Your Business' : 'Join CampusWork',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isBusiness
                        ? 'Connect with talented students'
                        : 'Start browsing jobs and connecting',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Role selector chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoleChip('Student', Icons.school_outlined),
                      const SizedBox(width: 12),
                      _buildRoleChip('Business', Icons.business_outlined),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form ──
            FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel(
                        isBusiness
                            ? "Business Logo (Optional)"
                            : "Profile Photo (Optional)",
                        isRequired: false,
                      ),
                      _buildImageUploader(isBusiness),
                      const SizedBox(height: 24),

                      if (isBusiness)
                        ..._buildBusinessFields()
                      else
                        ..._buildStudentFields(),
                      const SizedBox(height: 20),

                      _buildInputLabel("Password"),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Create a strong password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 8)
                            ? 'Must be at least 8 characters'
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          "Must be at least 8 characters long",
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleSignUp,
                          child: Text(
                            isBusiness
                                ? "Create Business Account"
                                : "Create Student Account",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: _buildFooterLink(
                          "Already have an account?",
                          "Sign in",
                          () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Role Chip ──
  Widget _buildRoleChip(String role, IconData icon) {
    final isSelected = _vm.selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _vm.setRole(role)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              role,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image Uploader ──
  Widget _buildImageUploader(bool isBusiness) {
    final cs = Theme.of(context).colorScheme;
    final image = _vm.profileImage;
    final isSaving = _vm.isSavingImage;

    return GestureDetector(
      onTap: isSaving ? null : _showImageSourceSheet,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(isBusiness ? 16 : 45),
                  border: Border.all(
                    color: image != null ? cs.primary : cs.outlineVariant,
                    width: image != null ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(isBusiness ? 14 : 43),
                  child: isSaving
                      ? Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: cs.primary,
                            ),
                          ),
                        )
                      : image != null
                          ? Image.file(image,
                              fit: BoxFit.cover, width: 90, height: 90)
                          : Icon(
                              isBusiness
                                  ? Icons.business
                                  : Icons.person_outline,
                              size: 42,
                              color: cs.outline,
                            ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    image != null ? Icons.edit : Icons.camera_alt,
                    size: 14,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSaving
                      ? "Saving image..."
                      : image != null
                          ? (isBusiness ? "Logo saved ✓" : "Photo saved ✓")
                          : (isBusiness
                              ? "Upload business logo"
                              : "Upload profile photo"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: image != null ? cs.primary : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSaving
                      ? "Please wait..."
                      : image != null
                          ? "Saved to device · tap to change or remove"
                          : "Tap to open camera or gallery",
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Student Fields ──
  List<Widget> _buildStudentFields() {
    return [
      _buildInputLabel("Full Name"),
      TextFormField(
        controller: _fullNameController,
        decoration: const InputDecoration(
          hintText: 'John Doe',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (v) => v!.isEmpty ? 'Enter name' : null,
      ),
      const SizedBox(height: 20),
      _buildInputLabel("Phone Number"),
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          hintText: '+1 234 567 8900',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        validator: (v) => v!.isEmpty ? 'Enter phone' : null,
      ),
      const SizedBox(height: 20),
      _buildInputLabel("Date of Birth", isRequired: false),
      TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: const InputDecoration(
          hintText: 'mm/dd/yyyy',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => _dobController.text =
                "${picked.month}/${picked.day}/${picked.year}");
          }
        },
      ),
      const SizedBox(height: 20),
      _buildInputLabel("Email Address"),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'student@university.edu',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: (v) => (!v!.contains('@')) ? 'Valid email required' : null,
      ),
    ];
  }

  // ── Business Fields ──
  List<Widget> _buildBusinessFields() {
    final cs = Theme.of(context).colorScheme;
    return [
      _buildInputLabel("Business Name"),
      TextFormField(
        controller: _businessNameController,
        decoration: const InputDecoration(
          hintText: 'ABC Company Inc.',
          prefixIcon: Icon(Icons.business),
        ),
        validator: (v) => v!.isEmpty ? 'Enter business name' : null,
      ),
      const SizedBox(height: 20),
      _buildInputLabel("Business Email"),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'contact@company.com',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: (v) => (!v!.contains('@')) ? 'Valid email required' : null,
      ),
      const SizedBox(height: 20),
      _buildInputLabel("Business Location"),
      TextFormField(
        controller: _locationController,
        decoration: const InputDecoration(
          hintText: 'City, State',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
        validator: (v) => v!.isEmpty ? 'Enter location' : null,
      ),
      const SizedBox(height: 20),
      _buildInputLabel("Contact Phone Number(s)"),
      ..._businessPhoneControllers.asMap().entries.map((entry) {
        int idx = entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: entry.value,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone number ${idx + 1}',
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (v) =>
                (v!.isEmpty && idx == 0) ? 'Enter phone' : null,
          ),
        );
      }),
      if (_businessPhoneControllers.length < 3)
        OutlinedButton.icon(
          onPressed: () => setState(
            () => _businessPhoneControllers.add(TextEditingController()),
          ),
          icon: const Icon(Icons.add),
          label: const Text("Add another phone number"),
        ),
      const SizedBox(height: 20),
      _buildInputLabel("Business Field"),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _vm.businessFields.map((field) {
          final isSelected = _vm.selectedBusinessField == field;
          return ChoiceChip(
            label: Text(field),
            selected: isSelected,
            onSelected: (selected) =>
                setState(() => _vm.setBusinessField(selected ? field : null)),
            selectedColor: cs.primaryContainer,
            backgroundColor: cs.surfaceContainerHighest,
            labelStyle: TextStyle(
              color: isSelected ? cs.primary : cs.onSurface,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
            ),
          );
        }).toList(),
      ),
      if (!_vm.isBusinessFieldValid)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            "Please select a business field",
            style: TextStyle(color: cs.error, fontSize: 12),
          ),
        ),
    ];
  }

  // ── Helpers ──
  Widget _buildInputLabel(String label, {bool isRequired = true}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
            fontSize: 15,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: " *",
                style: TextStyle(color: cs.error),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, String linkText, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$text ",
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}