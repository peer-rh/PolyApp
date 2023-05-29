import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/logic/purchases.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class MembershipPage extends ConsumerWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider).value;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(
        title: Text("Membership"),
      ),
      body: switch (isPremium) {
        null => const LoadingPage(),
        true => const ManageMembershipPage(),
        false => const PurchaseMembershipPage()
      },
    );
  }
}

class ManageMembershipPage extends ConsumerWidget {
  const ManageMembershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text("Manage Membership Page"),
    );
  }
}

class PurchaseMembershipPage extends ConsumerWidget {
  const PurchaseMembershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final offerings = ref.watch(purchasesProvider).offerings;
    // if (offerings == null) {
    // return const Center(child: CircularProgressIndicator());
    // }
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Text("Choose a plan",
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Text("Unlock all lessons, unlimited Languages and custom Lessons!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 64),
          Wrap(alignment: WrapAlignment.center, spacing: 32, children: [
            InkWell(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
                      ),
                      height: 80,
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        "1 Month",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.4),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                      ),
                      height: 80,
                      width: 100,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "€9.99",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                          Text("€9.99 / mo",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                        ],
                      ),
                    ),
                  ],
                )),
            InkWell(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
                      ),
                      height: 80,
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        "1 Year",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                      ),
                      height: 80,
                      width: 100,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "€69.99",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                          Text("€5.83 / mo",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                        ],
                      ),
                    ),
                  ],
                ))
          ]),
          const SizedBox(height: 64),
          Text(
              "The subscriptions will auto-renew until you cancel. Charges will apply until next billing period.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          FilledButton(
            onPressed: () {},
            style: ButtonStyle(
                minimumSize:
                    MaterialStateProperty.all(const Size.fromHeight(48)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
            child: const Text("Purchase"),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
