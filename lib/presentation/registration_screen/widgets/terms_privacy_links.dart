import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TermsPrivacyLinks extends StatelessWidget {
  const TermsPrivacyLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          children: [
            const TextSpan(
              text: 'By creating an account, you agree to our ',
            ),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _showTermsDialog(context);
                },
            ),
            const TextSpan(
              text: ' and ',
            ),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _showPrivacyDialog(context);
                },
            ),
            const TextSpan(
              text: '.',
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Terms of Service',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Text(
              'Welcome to TeamSync Calendar. By using our service, you agree to these terms.\n\n'
              '1. Account Creation: You must provide accurate information when creating your account.\n\n'
              '2. Team Collaboration: You are responsible for maintaining the confidentiality of your team invitation codes.\n\n'
              '3. Data Usage: We collect and use your data to provide calendar synchronization services.\n\n'
              '4. Service Availability: We strive to maintain 99.9% uptime but cannot guarantee uninterrupted service.\n\n'
              '5. User Conduct: You agree not to misuse our service or interfere with other users\' experience.\n\n'
              'For complete terms, visit our website.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Privacy Policy',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Text(
              'Your privacy is important to us. This policy explains how we collect, use, and protect your information.\n\n'
              '1. Information Collection: We collect account information, calendar data, and usage analytics.\n\n'
              '2. Data Usage: Your data is used to provide calendar synchronization and team collaboration features.\n\n'
              '3. Data Sharing: We do not sell your personal information to third parties.\n\n'
              '4. Data Security: We use industry-standard encryption to protect your data.\n\n'
              '5. Data Retention: We retain your data as long as your account is active.\n\n'
              '6. Your Rights: You can request access, correction, or deletion of your personal data.\n\n'
              'For our complete privacy policy, visit our website.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
