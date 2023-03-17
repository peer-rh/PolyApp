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
