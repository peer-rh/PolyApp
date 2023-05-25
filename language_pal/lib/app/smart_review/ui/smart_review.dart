import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/ui/learn_track_layover.dart';
import 'package:poly_app/app/smart_review/logic/errors.dart';
import 'package:poly_app/app/smart_review/ui/error_review.dart';
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
              CustomNavListItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReviewErrorScreen()));
                  },
                  enabled: true,
                  title: Text(
                    (nErrors == 0) ? "No errors" : "Review $nErrors errors",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  icon: CustomIcons.redo),
            ],
          )),
    );
  }
}
