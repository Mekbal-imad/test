import 'package:url_launcher/url_launcher.dart';

/// Result of attempting to contact employer via email
enum EmailContactResult {
  success,
  noEmailProvided,
  invalidEmailFormat,
  noEmailAppInstalled,
  unknownError,
}

class EmailHelper {
  /// Attempts to open email app with pre-filled message
  ///
  /// Returns a [EmailContactResult] indicating what happened
  static Future<EmailContactResult> contactEmployer({
    required String? email,
    String subject = 'Job Inquiry',
    String body =
        'Hello, I am interested in your job posting. Please provide more details.',
  }) async {
    // Check 1: No email provided
    if (email == null || email.isEmpty) {
      return EmailContactResult.noEmailProvided;
    }

    // Check 2: Invalid email format (basic validation)
    if (!_isValidEmail(email)) {
      return EmailContactResult.invalidEmailFormat;
    }

    final emailUrl = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    // Check 3: Can the device handle this URL?
    final canLaunch = await canLaunchUrl(emailUrl);
    if (!canLaunch) {
      return EmailContactResult.noEmailAppInstalled;
    }

    // Check 4: Try to launch
    try {
      final launched = await launchUrl(
        emailUrl,
        mode: LaunchMode.externalApplication,
      );
      return launched
          ? EmailContactResult.success
          : EmailContactResult.unknownError;
    } catch (_) {
      return EmailContactResult.unknownError;
    }
  }

  /// Basic email format validation
  static bool _isValidEmail(String email) {
    // Simple regex: must have @ and . after @
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  /// Returns user-friendly message for each result
  static String getMessage(EmailContactResult result) {
    switch (result) {
      case EmailContactResult.success:
        return ''; // No message needed
      case EmailContactResult.noEmailProvided:
        return 'No email available for this employer.';
      case EmailContactResult.invalidEmailFormat:
        return 'Invalid email format for this employer. Please contact them through other means.';
      case EmailContactResult.noEmailAppInstalled:
        return 'No email app found. Please install Gmail or another email app.';
      case EmailContactResult.unknownError:
        return 'Could not open email app. Please check your email settings.';
    }
  }
}
