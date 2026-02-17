import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/monetization_bloc.dart';
import '../bloc/monetization_state.dart';

/// Banner ad widget that only shows for free-tier users.
/// Self-managing: loads ad on init, disposes on destroy, handles errors silently.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    final adUnitId = Platform.isAndroid
        ? AppConstants.bannerAdUnitIdAndroid
        : AppConstants.bannerAdUnitIdIos;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonetizationBloc, MonetizationState>(
      builder: (context, state) {
        // Don't show ads for premium users
        if (state is MonetizationPremiumActive) {
          return const SizedBox.shrink();
        }

        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox(height: 50); // Placeholder to prevent layout shift
        }

        return Container(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
