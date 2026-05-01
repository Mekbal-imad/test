import 'package:flutter/material.dart';
import 'package:job_bit/services/auth_service.dart';
import 'package:job_bit/screens/jobs_screen.dart';
import 'package:job_bit/screens/post_job_screen.dart';
import 'package:job_bit/screens/profile/profile_screen.dart';
import 'package:job_bit/screens/profile/business_profile_screen.dart';
import 'package:job_bit/screens/auth/auth_required_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  int selectedIndex = 0;

  bool get _isBusiness => _auth.currentRole == 'Business';
  bool get _isLoggedIn => _auth.isAuthenticated;

  Widget _buildProfilePage() {
    if (_isBusiness && _auth.currentBusinessProfile != null) {
      return BusinessProfileScreen(business: _auth.currentBusinessProfile!);
    }
    if (_isLoggedIn && _auth.currentStudentProfile != null) {
      return ProfileScreen(user: _auth.currentStudentProfile!);
    }
    return const AuthRequiredScreen(
      title: 'Profile required',
      message: 'Sign in to create or edit your profile.',
    );
  }

  List<Widget> _buildPages() {
    if (_isBusiness) {
      return [
        const JobsScreen(),
        const PostJobScreen(),
        _buildProfilePage(),
      ];
    }
    // Student or not logged in — no Post Job tab
    return [
      const JobsScreen(),
      _buildProfilePage(),
    ];
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    if (_isBusiness) {
      return const [
        BottomNavigationBarItem(
          label: 'Jobs',
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
        ),
        BottomNavigationBarItem(
          label: 'Post Job',
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
        ),
        BottomNavigationBarItem(
          label: 'Profile',
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
        ),
      ];
    }
    // Student or not logged in
    return const [
      BottomNavigationBarItem(
        label: 'Jobs',
        icon: Icon(Icons.work_outline),
        activeIcon: Icon(Icons.work),
      ),
      BottomNavigationBarItem(
        label: 'Profile',
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
    final navItems = _buildNavItems();

    // Clamp selectedIndex in case it's out of bounds after role change
    if (selectedIndex >= pages.length) {
      selectedIndex = 0;
    }

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: navItems,
      ),
    );
  }
}