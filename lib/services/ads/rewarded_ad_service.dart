import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAdService._();

  static final RewardedAdService instance = RewardedAdService._();

  String? get _rewardedAdUnitId {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/5224354917';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/1712485313';
      default:
        return null;
    }
  }

  Future<RewardedAd?> _loadRewardedAd(String adUnitId) async {
    final completer = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (!completer.isCompleted) {
            completer.complete(ad);
          }
        },
        onAdFailedToLoad: (error) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
    );

    return completer.future;
  }

  Future<bool> _showLoadedRewardedAd(RewardedAd ad) async {
    final completer = Completer<bool>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.setImmersiveMode(true);
    ad.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
      },
    );

    return completer.future;
  }

  Future<bool> showRewardedAd() async {
    final adUnitId = _rewardedAdUnitId;
    if (adUnitId == null) {
      return false;
    }

    final ad = await _loadRewardedAd(adUnitId);
    if (ad == null) {
      return false;
    }

    return _showLoadedRewardedAd(ad);
  }

  Future<bool> showRewardedAdsSequence({
    required int count,
    void Function(int validatedAds, int totalAds)? onAdValidated,
  }) async {
    if (count <= 0) {
      return false;
    }

    final adUnitId = _rewardedAdUnitId;
    if (adUnitId == null) {
      return false;
    }

    final firstAd = await _loadRewardedAd(adUnitId);
    if (firstAd == null) {
      return false;
    }
    RewardedAd currentAd = firstAd;

    for (int index = 0; index < count; index++) {
      final nextAdFuture = index < count - 1
          ? _loadRewardedAd(adUnitId)
          : Future<RewardedAd?>.value(null);

      final rewardEarned = await _showLoadedRewardedAd(currentAd);
      if (!rewardEarned) {
        return false;
      }

      onAdValidated?.call(index + 1, count);

      if (index < count - 1) {
        final nextAd = await nextAdFuture;
        if (nextAd == null) {
          return false;
        }
        currentAd = nextAd;
      }
    }

    return true;
  }
}