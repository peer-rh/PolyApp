import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/lessons/common/input/ui.dart';
import 'package:poly_app/app/lessons/vocab/vocab_prompt.dart';
import 'package:poly_app/app/smart_review/logic/errors.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class ReviewErrorScreen extends ConsumerStatefulWidget {
  const ReviewErrorScreen({Key? key}) : super(key: key);

  @override
  ReviewErrorScreenState createState() => ReviewErrorScreenState();
}

class ReviewErrorScreenState extends ConsumerState<ReviewErrorScreen> {
  String currentAnswer = "";
  int currentKey = 1;

  @override
  Widget build(BuildContext context) {
    final err = ref.watch(userErrorProvider);
    final step = err.currentStep;
    return Scaffold(
      appBar: const FrostedAppBar(title: Text("Review Errors")),
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
                  "Congratulations!",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "You have no errors left to review!",
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
                        err.submitAnswer(currentAnswer);
                        setState(() {
                          currentAnswer = "";
                        });
                      },
                      onSkip: () {
                        currentAnswer = "";
                        err.submitAnswer(currentAnswer);
                        err.nextStep();
                      },
                      currentAnswer: currentAnswer,
                      key: Key(currentKey.toString()),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: step.userAnswer != null
                          ? () {
                              err.nextStep();
                              currentAnswer = "";
                              currentKey++;
                            }
                          : currentAnswer == ""
                              ? null
                              : () => err.submitAnswer(currentAnswer),
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
