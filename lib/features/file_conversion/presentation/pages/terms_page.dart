import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Terms of Use page.
/// Displays the app's terms of service to comply with Google Play Store requirements.
class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Use',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),

            _Section(
              title: '1. Acceptance of Terms',
              content:
                  'By downloading, installing, or using ${AppConstants.appName}, '
                  'you agree to be bound by these Terms of Use. If you do not agree, '
                  'please do not use the app.',
            ),

            _Section(
              title: '2. Description of Service',
              content:
                  '${AppConstants.appName} is a file conversion application that allows you to '
                  'convert files between different formats (PDF, DOCX, TXT, Images). '
                  'All file processing is performed locally on your device.',
            ),

            _Section(
              title: '3. Free and Premium Tiers',
              content:
                  'The app offers both free and premium tiers:\n\n'
                  'Free Tier:\n'
                  '• Up to ${AppConstants.maxFreeConversionsPerDay} conversions per day\n'
                  '• Advertisements displayed\n'
                  '• Basic conversion features\n\n'
                  'Premium Tier (Subscription):\n'
                  '• Unlimited conversions\n'
                  '• No advertisements\n'
                  '• High-speed processing mode\n'
                  '• Advanced output settings\n'
                  '• Batch processing (up to 10 files)',
            ),

            _Section(
              title: '4. Subscriptions & Payments',
              content:
                  'Premium subscriptions are available as Weekly (₦500/week), '
                  'Monthly (₦1,500/month), and Yearly (₦12,000/year) plans.\n\n'
                  '• Payment is charged to your Google Play account at confirmation of purchase\n'
                  '• Subscriptions automatically renew unless cancelled at least 24 hours '
                  'before the end of the current period\n'
                  '• You can manage and cancel subscriptions in Google Play Store settings\n'
                  '• No refunds for partial subscription periods',
            ),

            _Section(
              title: '5. Acceptable Use',
              content:
                  'You agree not to:\n'
                  '• Use the app for illegal purposes\n'
                  '• Convert files that infringe on copyright or intellectual property rights\n'
                  '• Attempt to reverse-engineer, decompile, or disassemble the app\n'
                  '• Circumvent any usage limits or security measures\n'
                  '• Use the app to process malicious or harmful content',
            ),

            _Section(
              title: '6. File Size & Format Limits',
              content:
                  '• Maximum file size: 50 MB per file\n'
                  '• Maximum batch size: 10 files\n'
                  '• Supported input formats: PDF, DOCX, TXT, JPG, JPEG, PNG\n'
                  '• Conversion quality depends on the source file quality',
            ),

            _Section(
              title: '7. Disclaimer of Warranties',
              content:
                  '${AppConstants.appName} is provided "as is" without warranty of any kind. '
                  'We do not guarantee that:\n'
                  '• Conversions will be error-free or perfectly formatted\n'
                  '• The app will be available at all times\n'
                  '• All file types will be supported\n\n'
                  'Some PDFs with complex formatting, encrypted content, or scanned images '
                  'may not convert accurately.',
            ),

            _Section(
              title: '8. Limitation of Liability',
              content:
                  'We are not liable for any data loss, file corruption, or damages '
                  'arising from the use of this app. Always keep backup copies of your '
                  'original files before conversion.',
            ),

            _Section(
              title: '9. Intellectual Property',
              content:
                  '${AppConstants.appName} and its original content, features, and functionality '
                  'are owned by the developer and are protected by international copyright '
                  'and intellectual property laws.',
            ),

            _Section(
              title: '10. Changes to Terms',
              content:
                  'We reserve the right to modify these Terms at any time. '
                  'Continued use of the app after changes constitutes acceptance of the new terms.',
            ),

            _Section(
              title: '11. Contact',
              content:
                  'For questions about these Terms, contact us:\n'
                  'Email: support@fileconverterpro.app',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
