import 'package:flutter/material.dart';
import 'package:job_bit/providers/job_provider.dart';
import 'package:job_bit/screens/auth/login_screen.dart';
import 'package:job_bit/screens/home_screen.dart';
import 'package:job_bit/screens/post_job_screen.dart';
import 'package:job_bit/screens/posted_jobs.dart';
import 'package:job_bit/screens/saved_jobs.dart';
import 'package:provider/provider.dart';
import 'package:job_bit/providers/theme_provider.dart';
import 'package:job_bit/theme/app_theme.dart';
import 'package:job_bit/update_screen.dart';
import 'package:job_bit/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'JobS',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          routes: {
            '/': (context) => const SplashScreen(),
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/post-job': (context) => const PostJobScreen(),
            '/profile/savedjobs': (context) => const SavedJobs(),
            '/profile/posted-jobs': (context) => const PostedJobs(),
            '/update': (context) => const UpdateScreen(),
          },
        );
      },
    );
  }
}
