import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> initPurchasesPlatfomState() async {
  await Purchases.setLogLevel(LogLevel.debug);

  late PurchasesConfiguration config;
  if (Platform.isAndroid) {
    // TODO: config = PurchasesConfiguration(<public_google_sdk_key>);
  } else if (Platform.isIOS) {
    config = PurchasesConfiguration(dotenv.env["REVENUE_CAT_IOS"]!);
  }
  await Purchases.configure(config);
}

final purchasesProvider = ChangeNotifierProvider<PurchasesProvider>((ref) {
  final uid = ref.watch(authProvider).currentUser?.uid;
  return PurchasesProvider(uid);
});
final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  return await ref.watch(purchasesProvider).getCustomerInfo();
});

final isPremiumProvider = FutureProvider<bool>((ref) async {
  final customerInfo = await ref.watch(customerInfoProvider.future);
  return customerInfo.entitlements.all["premium"]?.isActive ?? false;
});

class PurchasesProvider extends ChangeNotifier {
  Offerings? _offerings;
  Offerings? get offerings => _offerings;

  PurchasesProvider(String? uid) {
    if (uid != null) {
      Purchases.logIn(uid);
    }

    _loadOfferings();
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  void _loadOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void makePurchase(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void restorePurchase() async {
    try {
      await Purchases.restorePurchases();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void manageSubscription() async {
    final url = (await Purchases.getCustomerInfo()).managementURL!;
    launchUrl(Uri.parse(url));
  }
}
