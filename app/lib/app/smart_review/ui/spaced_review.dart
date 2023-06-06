import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/lessons/common/input/ui.dart';
import 'package:poly_app/app/lessons/vocab/vocab_prompt.dart';
import 'package:poly_app/app/smart_review/logic/spaced_review.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class SpacedReviewScreen extends ConsumerStatefulWidget {
  final String title;
  const SpacedReviewScreen({this.title = "Smart Review", Key? key})
      : super(key: key);

  @override
  SpacedReviewScreenState createState() => SpacedReviewScreenState();
}

class SpacedReviewScreenState extends ConsumerState<SpacedReviewScreen> {
  String currentAnswer = "";
  int currentKey = 1;

  @override
  Widget build(BuildContext context) {
    final srP = ref.watch(spacedReviewProvider);
    final step = srP.currentStep;
    return Scaffold(
      appBar: FrostedAppBar(title: Text(widget.title)),
      extendBodyBehindAppBar: true,
      body: step == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                    alignment: Alignment.center,
                    child: AIAvatar(
                      "poly",
                      radius: 64,
                    )),
                const SizedBox(height: 16),
                Text(
                  "Nothing to review!",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "You have to finish lessons to have vocabulary to review.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    VocabPrompt(step: step),
                    const SizedBox(height: 32),
                    VocabInputWidget(
                      step: step,
                      onChange: (String ans) {
                        currentAnswer = ans;
                        setState(() {});
                      },
                      onSubmit: () {
                        srP.submitAnswer(currentAnswer);
                        setState(() {
                          currentAnswer = "";
                        });
                      },
                      onSkip: () {
                        currentAnswer = "";
                        srP.submitAnswer(currentAnswer);
                        srP.nextStep();
                      },
                      currentAnswer: currentAnswer,
                      key: Key(currentKey.toString()),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: step.userAnswer != null
                          ? () {
                              srP.nextStep();
                              currentAnswer = "";
                              currentKey++;
                              setState(() {});
                            }
                          : currentAnswer == ""
                              ? null
                              : () => srP.submitAnswer(currentAnswer),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: currentAnswer == "" &&
                                    step.userAnswer == null
                                ? Theme.of(context).colorScheme.surfaceVariant
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          step.userAnswer != null ? 'Next' : 'Check',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
