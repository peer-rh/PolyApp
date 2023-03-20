import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(LogLevel.error);

  late PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration(dotenv.env["REVENUE_CAT_ANDROID"]!);
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration(dotenv.env["REVENUE_CAT_IOS"]!);
  }
  await Purchases.configure(configuration);
  final analysisId = await FirebaseAnalytics.instance.appInstanceId;
  Purchases.setFirebaseAppInstanceId(analysisId!);
}

// NOTE:
// 3 Levels
// Lite: 3.99$ per month - Limited Messages - Ads for more messages
// Base: 7.99$ per month - Unlimited Messages - No Ads - Whisper Input
// Pro: 14.99$ per month - Unlimited Messages - GPT-4
