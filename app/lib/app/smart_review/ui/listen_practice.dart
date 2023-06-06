import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/smart_review/logic/spaced_review.dart';
import 'package:poly_app/app/smart_review/ui/spaced_review.dart';

class ListenPracticeScreen extends ConsumerStatefulWidget {
  const ListenPracticeScreen({super.key});

  @override
  ListenPracticeScreenState createState() => ListenPracticeScreenState();
}

class ListenPracticeScreenState extends ConsumerState<ListenPracticeScreen> {
  late SpacedReviewProvider sess;
  @override
  void dispose() {
    Future(() {
      sess.staticType = null;
    });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    sess = ref.watch(spacedReviewProvider);
    Future(() {
      sess.staticType = InputType.listen;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return const SpacedReviewScreen(
      title: "Listening Exercises",
    );
  }
}
