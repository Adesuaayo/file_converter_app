import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/monetization_bloc.dart';
import '../bloc/monetization_event.dart';
import '../bloc/monetization_state.dart';

/// Premium upgrade page.
/// Presents premium features, pricing, and purchase/restore buttons.
class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<MonetizationBloc, MonetizationState>(
        listener: (context, state) {
          if (state is MonetizationPurchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome to Premium! Enjoy unlimited conversions.'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
          if (state is MonetizationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Premium icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706).withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Unlock Premium',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'One-time purchase. No subscription.',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 32),

                // Feature list
                _PremiumFeature(
                  icon: Icons.all_inclusive_rounded,
                  title: 'Unlimited Conversions',
                  subtitle: 'No daily limits on file conversions',
                ),
                _PremiumFeature(
                  icon: Icons.block_rounded,
                  title: 'No Advertisements',
                  subtitle: 'Clean, distraction-free experience',
                ),
                _PremiumFeature(
                  icon: Icons.speed_rounded,
                  title: 'High-Speed Mode',
                  subtitle: 'Priority processing for faster conversions',
                ),
                _PremiumFeature(
                  icon: Icons.tune_rounded,
                  title: 'Advanced Settings',
                  subtitle: 'Custom compression and quality controls',
                ),
                _PremiumFeature(
                  icon: Icons.folder_copy_rounded,
                  title: 'Batch Processing',
                  subtitle: 'Convert up to 10 files at once',
                ),

                const SizedBox(height: 40),

                // Purchase button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state is MonetizationPurchasing
                        ? null
                        : () {
                            context.read<MonetizationBloc>().add(
                                  const PremiumPurchaseRequested(
                                    AppConstants.premiumProductId,
                                  ),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state is MonetizationPurchasing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Upgrade Now',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Restore purchases button
                TextButton(
                  onPressed: () {
                    context.read<MonetizationBloc>().add(
                          const PurchaseRestoreRequested(),
                        );
                  },
                  child: Text(
                    'Restore Purchases',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Legal text
                Text(
                  'Payment will be charged to your App Store or Google Play account. '
                  'This is a one-time purchase.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD97706),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }
}
