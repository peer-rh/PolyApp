import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/chat_common/components/chat_bubble.dart';
import 'package:poly_app/app/chat_common/components/input_area.dart';
import 'package:poly_app/app/user/logic/onboarding_session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/frosted_effect.dart';
import 'package:poly_app/common/ui/measure_size.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  double _offset = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeOnboardingSession);
    return Scaffold(
      appBar: const FrostedAppBar(title: Text("Welcome")),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: double.infinity,
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: SingleChildScrollView(
                controller: _scrollController,
                reverse: true,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  children: [
                    ...session.msgs.map((e) => switch (e.isAi) {
                          true => AiMsgBubbleFrame(
                              avatar: AIAvatar("Poly"),
                              child: Text(
                                e.msg,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                              )),
                          false => UserMsgBubbleFrame(
                                child: Text(
                              e.msg,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                            )),
                        }),
                    session.state == OnboardingState.waitingForAI
                        ? const AIMsgBubbleLoading("Poly")
                        : const SizedBox(),
                    SizedBox(
                      height: _offset,
                    )
                  ],
                ),
              ),
            ),
            // ConversationColumn(conv: conv, scenario: scenario),
            MeasureSize(
              onChange: (size) {
                setState(() {
                  _offset = size.height;
                });
              },
              child: FrostedEffect(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(children: [
                    Expanded(
                        child: ChatTextField(
                            controller: _textController,
                            onSubmitted: session.state !=
                                    OnboardingState.waitingForUser
                                ? null
                                : (_) =>
                                    session.addUserMsg(_textController.text),
                            hintText: AppLocalizations.of(context)!
                                .chat_input_hint_reg)),
                    const SizedBox(width: 8),
                    SendButton(
                        onPressed: () {
                          session.addUserMsg(_textController.text);
                        },
                        enabled:
                            session.state == OnboardingState.waitingForUser)
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
