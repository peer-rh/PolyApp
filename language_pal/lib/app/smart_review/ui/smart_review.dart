import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/smart_review/logic/errors.dart';
import 'package:poly_app/app/smart_review/ui/error_review.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/custom_nav_item.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class SmartReviewPage extends ConsumerWidget {
  const SmartReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nErrors = ref.watch(userErrorProvider).steps.length;
    return Scaffold(
      appBar: const FrostedAppBar(
        title: Text('Smart Review'),
      ),
      body: Container(
          padding: const EdgeInsets.all(16),
          child: CustomNavListItem(
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
              icon: CustomIcons.redo)),
    );
  }
}
