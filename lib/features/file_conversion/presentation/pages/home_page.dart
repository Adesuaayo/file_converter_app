import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/conversion_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../monetization/presentation/bloc/monetization_bloc.dart';
import '../../../monetization/presentation/bloc/monetization_event.dart';
import '../../../monetization/presentation/bloc/monetization_state.dart';
import '../../../monetization/presentation/widgets/ad_banner_widget.dart';
import '../bloc/conversion_bloc.dart';
import '../bloc/conversion_event.dart';
import '../bloc/conversion_state.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/theme_cubit.dart';
import '../widgets/file_type_card.dart';
import 'conversion_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

/// Main home page with bottom navigation.
/// Displays conversion type grid, history, and settings tabs.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load monetization status on app start
    context.read<MonetizationBloc>().add(const MonetizationStatusChecked());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          HistoryPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            // Refresh history when navigating to history tab
            context.read<HistoryBloc>().add(const HistoryLoaded());
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Home tab content — conversion type grid with banner ad.
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // App logo/title
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FileConverter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Pro',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Premium badge or theme toggle
                BlocBuilder<MonetizationBloc, MonetizationState>(
                  builder: (context, state) {
                    if (state is MonetizationPremiumActive) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.premiumGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                  icon: BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return Icon(
                        switch (themeMode) {
                          ThemeMode.light => Icons.light_mode_rounded,
                          ThemeMode.dark => Icons.dark_mode_rounded,
                          ThemeMode.system => Icons.brightness_auto_rounded,
                        },
                        size: 22,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Remaining conversions indicator (free tier only)
          BlocBuilder<MonetizationBloc, MonetizationState>(
            builder: (context, monetizationState) {
              if (monetizationState is MonetizationPremiumActive) {
                return const SizedBox.shrink();
              }
              return _buildRemainingConversions(context);
            },
          ),

          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Text(
                  'Convert Files',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  'Select type',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Conversion type grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: ConversionType.values.map((type) {
                  return FileTypeCard(
                    conversionType: type,
                    onTap: () => _navigateToConversion(context, type),
                  );
                }).toList(),
              ),
            ),
          ),

          // Banner ad (free tier only)
          BlocBuilder<MonetizationBloc, MonetizationState>(
            builder: (context, state) {
              if (state is MonetizationPremiumActive) {
                return const SizedBox.shrink();
              }
              return const AdBannerWidget();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingConversions(BuildContext context) {
    return BlocBuilder<ConversionBloc, ConversionState>(
      builder: (context, state) {
        // Trigger check on initial or when returning from conversion
        if (state is ConversionInitial || state is ConversionSuccess) {
          // Use addPostFrameCallback to avoid emitting during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<ConversionBloc>().add(
                    const RemainingConversionsChecked(),
                  );
            }
          });
        }

        int remaining = 5; // Default
        if (state is RemainingConversionsLoaded) {
          remaining = state.remaining;
        } else if (state is ConversionTypeReady) {
          remaining = state.remainingConversions;
        } else if (state is ConversionReady) {
          remaining = state.remainingConversions;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$remaining conversions remaining today',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.info,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToPremium(context),
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToConversion(BuildContext context, ConversionType type) {
    context.read<ConversionBloc>().add(ConversionTypeSelected(type));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConversionPage(),
      ),
    ).then((_) {
      // Refresh remaining conversions when returning from conversion page
      if (context.mounted) {
        context.read<ConversionBloc>().add(const RemainingConversionsChecked());
      }
    });
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SettingsPage(), // Navigate to settings which has premium option
      ),
    );
  }
}
