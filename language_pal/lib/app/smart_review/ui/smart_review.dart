import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/ui/learn_track_layover.dart';
import 'package:poly_app/app/smart_review/logic/errors.dart';
import 'package:poly_app/app/smart_review/ui/error_review.dart';
import 'package:poly_app/app/smart_review/ui/listen_practice.dart';
import 'package:poly_app/app/smart_review/ui/pronunciation_practice.dart';
import 'package:poly_app/app/smart_review/ui/spaced_review.dart';
import 'package:poly_app/common/logic/languages.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/custom_nav_item.dart';
import 'package:poly_app/common/ui/flag.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class SmartReviewPage extends ConsumerWidget {
  const SmartReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nErrors = ref.watch(userErrorProvider).steps.length;
    final spacer = Container(
        alignment: Alignment.centerLeft,
        child: Container(
            width: 2,
            height: 16,
            color: Theme.of(context).colorScheme.surfaceVariant,
            margin: const EdgeInsets.only(top: 4, bottom: 4, left: 28)));
    return Scaffold(
      appBar: FrostedAppBar(
        title: const SizedBox(),
        action: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showLearnTrackOverlay(context),
          child: Container(
            margin: const EdgeInsets.only(right: 24),
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 32,
              width: 42,
              child: Flag(code: ref.watch(learnLangProvider).code),
            ),
          ),
        ),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              Text("Smart Review",
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "0% completed",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              spacer,
              CustomNavListItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReviewErrorScreen()));
                  },
                  enabled: true,
                  title: Text(
                    (nErrors == 0)
                        ? "No errors to Review"
                        : "Review $nErrors errors",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  icon: CustomIcons.redo),
              spacer,
              CustomNavListItem(
                  onTap: () {},
                  enabled: false,
                  title: Text(
                    "Custom Topic",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  icon: Icons.paid), // TODO: UPdate with crown icon
              const SizedBox(height: 32),
              Text("Repetition",
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              CustomNavListItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SpacedReviewScreen()));
                  },
                  enabled: true,
                  title: Text(
                    "All Exercises",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  icon: CustomIcons.book),
              spacer,
              CustomNavListItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ListenPracticeScreen()));
                  },
                  enabled: true,
                  title: Text(
                    "Listening",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  icon: CustomIcons.headphones),
              spacer,

              CustomNavListItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PronunciationPracticeScreen()));
                  },
                  enabled: true,
                  title: Text(
                    "Pronunciation",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  icon: CustomIcons.mic),
            ],
          )),
    );
  }
}
