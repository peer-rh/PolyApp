import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/user/logic/purchases.dart';
import 'package:poly_app/common/ui/error_screen.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class MembershipPage extends ConsumerWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider).value;
    return switch (isPremium) {
      null => const LoadingPage(),
      true => const ManageMembershipPage(),
      false => const PurchaseMembershipPage()
    };
  }
}

class ManageMembershipPage extends ConsumerWidget {
  const ManageMembershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(customerInfoProvider).value;
    if (sub == null) {
      return const LoadingPage();
    }
    final willRenew = sub.entitlements.active["premium"]!.willRenew;
    final nextDate = sub.entitlements.active["premium"]!.expirationDate;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Manage Membership"),
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AIAvatar(
                  "Poly",
                  radius: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  "You are subscribed!",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "You are currently subscribed to Poly Premium.${willRenew ? "Your next billing date is $nextDate" : "Your subscription will stop $nextDate"}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                      minimumSize:
                          MaterialStateProperty.all(const Size.fromHeight(48)),
                    ),
                    onPressed: () {
                      ref.read(purchasesProvider).manageSubscription();
                    },
                    child: const Text("Manage Subscription"))
              ],
            )));
  }
}

class PurchaseMembershipPage extends ConsumerWidget {
  const PurchaseMembershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(purchasesProvider).offerings;
    if (offerings == null) {
      return const LoadingPage();
    }
    final yearly = offerings.current?.annual;
    final monthly = offerings.current?.monthly;
    if (yearly == null || monthly == null) {
      return const ErrorScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Membership"),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Poly Premium",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text("Access to all features, languages and more!"),
                const SizedBox(height: 24),
                FilledButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                    minimumSize:
                        MaterialStateProperty.all(const Size.fromHeight(48)),
                  ),
                  child: Text("${monthly.storeProduct.priceString} / month"),
                  onPressed: () {
                    ref.read(purchasesProvider).makePurchase(monthly);
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                    minimumSize:
                        MaterialStateProperty.all(const Size.fromHeight(48)),
                  ),
                  child: Text("${yearly.storeProduct.priceString} / year"),
                  onPressed: () {
                    ref.read(purchasesProvider).makePurchase(yearly);
                  },
                ),
                const SizedBox(height: 8),
                const Text("Save 45% at € 4.99/month"),
                const SizedBox(height: 24),
                TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                    ),
                    onPressed: () {
                      ref.read(purchasesProvider).restorePurchase();
                    },
                    child: const Text("Restore Purchase"))
              ],
            )),
      ),
    );
  }
}
