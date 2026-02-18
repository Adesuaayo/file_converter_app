import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Privacy Policy page.
/// Displays the app's privacy policy to comply with Google Play Store requirements.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
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
              title: '1. Information We Collect',
              content:
                  '${AppConstants.appName} processes all file conversions entirely on your device. '
                  'We do not upload, store, or transmit your files to any external server.\n\n'
                  'We may collect the following non-personal information:\n'
                  '• App usage analytics (conversion types, frequency)\n'
                  '• Device information (OS version, device model) for crash reporting\n'
                  '• Advertising identifiers for serving relevant ads (free tier only)',
            ),

            _Section(
              title: '2. How We Use Information',
              content:
                  'Any information collected is used solely to:\n'
                  '• Improve app performance and user experience\n'
                  '• Display relevant advertisements to free-tier users\n'
                  '• Process in-app purchases and subscriptions\n'
                  '• Fix bugs and crashes',
            ),

            _Section(
              title: '3. Data Storage',
              content:
                  'All converted files are stored locally on your device in the app\'s output directory. '
                  'Conversion history is stored locally using encrypted local storage. '
                  'No file data is ever sent to external servers.',
            ),

            _Section(
              title: '4. Third-Party Services',
              content:
                  'We use the following third-party services:\n'
                  '• Google AdMob — for displaying ads to free-tier users\n'
                  '• Google Play Billing — for processing subscription payments\n'
                  '• Google Play Services — for app functionality\n\n'
                  'These services may collect information as described in their respective privacy policies.',
            ),

            _Section(
              title: '5. Advertising',
              content:
                  'Free-tier users may see advertisements powered by Google AdMob. '
                  'Premium subscribers do not see any advertisements. '
                  'Google AdMob may use advertising identifiers and cookies to serve '
                  'personalized or non-personalized ads based on your preferences.',
            ),

            _Section(
              title: '6. Children\'s Privacy',
              content:
                  '${AppConstants.appName} is not directed to children under 13. '
                  'We do not knowingly collect personal information from children.',
            ),

            _Section(
              title: '7. Data Security',
              content:
                  'Since all file processing occurs locally on your device, your files remain '
                  'under your control at all times. We implement reasonable security measures '
                  'to protect any usage data collected.',
            ),

            _Section(
              title: '8. Your Rights',
              content:
                  'You can:\n'
                  '• Delete all conversion history from Settings > Storage > Clean Up\n'
                  '• Opt out of personalized ads in your device settings\n'
                  '• Uninstall the app to remove all local data\n'
                  '• Contact us for any data-related requests',
            ),

            _Section(
              title: '9. Changes to This Policy',
              content:
                  'We may update this Privacy Policy from time to time. '
                  'Any changes will be reflected in the app with an updated date.',
            ),

            _Section(
              title: '10. Contact Us',
              content:
                  'If you have questions about this Privacy Policy, please contact us:\n'
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
