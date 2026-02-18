import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/monetization_bloc.dart';
import '../bloc/monetization_event.dart';
import '../bloc/monetization_state.dart';

/// Premium upgrade page with subscription tiers.
/// Presents premium features, subscription plans, and purchase/restore buttons.
class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _selectedPlanIndex = 1; // Default to monthly (best value)

  static const _plans = [
    _SubscriptionPlan(
      title: 'Weekly',
      price: '₦500',
      period: '/week',
      productId: AppConstants.weeklySubscriptionId,
      savings: '',
    ),
    _SubscriptionPlan(
      title: 'Monthly',
      price: '₦1,500',
      period: '/month',
      productId: AppConstants.monthlySubscriptionId,
      savings: 'Save 25%',
    ),
    _SubscriptionPlan(
      title: 'Yearly',
      price: '₦12,000',
      period: '/year',
      productId: AppConstants.yearlySubscriptionId,
      savings: 'Save 54%',
    ),
  ];

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
                  'Choose the plan that works for you',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 28),

                // Subscription plan cards
                Row(
                  children: List.generate(_plans.length, (index) {
                    final plan = _plans[index];
                    final isSelected = _selectedPlanIndex == index;
                    final isBestValue = index == 1;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlanIndex = index),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: index > 0 ? 8 : 0,
                            right: index < _plans.length - 1 ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD97706).withOpacity(0.1)
                                : colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD97706)
                                  : colorScheme.outline.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (isBestValue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'BEST',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              Text(
                                plan.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                plan.price,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? const Color(0xFFD97706)
                                      : colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                plan.period,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              if (plan.savings.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  plan.savings,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 28),

                // Feature list
                const _PremiumFeature(
                  icon: Icons.all_inclusive_rounded,
                  title: 'Unlimited Conversions',
                  subtitle: 'No daily limits on file conversions',
                ),
                const _PremiumFeature(
                  icon: Icons.block_rounded,
                  title: 'No Advertisements',
                  subtitle: 'Clean, distraction-free experience',
                ),
                const _PremiumFeature(
                  icon: Icons.speed_rounded,
                  title: 'High-Speed Mode',
                  subtitle: 'Priority processing for faster conversions',
                ),
                const _PremiumFeature(
                  icon: Icons.tune_rounded,
                  title: 'Advanced Settings',
                  subtitle: 'Custom compression and quality controls',
                ),
                const _PremiumFeature(
                  icon: Icons.folder_copy_rounded,
                  title: 'Batch Processing',
                  subtitle: 'Convert up to 10 files at once',
                ),

                const SizedBox(height: 32),

                // Subscribe button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state is MonetizationPurchasing
                        ? null
                        : () {
                            context.read<MonetizationBloc>().add(
                                  PremiumPurchaseRequested(
                                    _plans[_selectedPlanIndex].productId,
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
                        : Text(
                            'Subscribe ${_plans[_selectedPlanIndex].title} — ${_plans[_selectedPlanIndex].price}${_plans[_selectedPlanIndex].period}',
                            style: const TextStyle(
                              fontSize: 16,
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
                  'Payment will be charged to your Google Play account. '
                  'Subscriptions auto-renew unless cancelled at least 24 hours '
                  'before the end of the current period. Manage subscriptions in '
                  'Google Play Store settings.',
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

/// Subscription plan data.
class _SubscriptionPlan {
  const _SubscriptionPlan({
    required this.title,
    required this.price,
    required this.period,
    required this.productId,
    required this.savings,
  });

  final String title;
  final String price;
  final String period;
  final String productId;
  final String savings;
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
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }
}
