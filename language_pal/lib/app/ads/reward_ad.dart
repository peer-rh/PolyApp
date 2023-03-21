
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void showAlertMsg(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Get 20 Extra Messages'),
        content:
            const Text("Do you want to view a short Ad to receive 20 free Messages?"),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              showRewardedAd();
            },
          ),
        ],
      );
    },
  );
}

void showRewardedAd() {
  final adUnitId = Platform.isAndroid
      ? dotenv.env["ADMOB_REWARD_KEY_ANDROID"]!
      : dotenv.env["ADMOB_REWARD_KEY_IOS"]!;

  RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          ad.show(onUserEarnedReward: (ad, reward) {
            // TODO: Enable
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ));
}
