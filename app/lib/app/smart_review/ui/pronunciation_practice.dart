import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/smart_review/logic/spaced_review.dart';
import 'package:poly_app/app/smart_review/ui/spaced_review.dart';

class PronunciationPracticeScreen extends ConsumerStatefulWidget {
  const PronunciationPracticeScreen({super.key});

  @override
  PronunciationPracticeScreenState createState() =>
      PronunciationPracticeScreenState();
}

class PronunciationPracticeScreenState
    extends ConsumerState<PronunciationPracticeScreen> {
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
      sess.staticType = InputType.pronounce;
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
