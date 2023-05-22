import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/chat_common/components/chat_bubble.dart';
import 'package:poly_app/app/chat_common/components/input_area.dart';
import 'package:poly_app/app/learn_track/data/learn_track_model.dart';
import 'package:poly_app/app/user/logic/onboarding_session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/frosted_effect.dart';
import 'package:poly_app/common/ui/measure_size.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final bool shouldPop;
  const OnboardingPage({this.shouldPop = false, Key? key}) : super(key: key);

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
    if (session.state == OnboardingState.finished) {
      if (ref
          .read(userProvider)!
          .learnTrackList
          .any((lt) => lt.llCode == session.result!.lang.code)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text("Already learning"),
                    content: Text(
                        "You are already learning ${session.result!.lang.getName(context)}. Aborting..."),
                  )).then((value) {
            if (widget.shouldPop) Navigator.of(context).pop();
          });
        });
      } else {
        Future(() {
          final newU = ref.read(userProvider)!.copyWithAddedLearnTrack(
              LearnTrackId(
                  id: session.result!.useCase.code,
                  llCode: session.result!.lang.code,
                  alCode: "en" // TODO: Change to system
                  ));
          ref.read(userProvider.notifier).setUser(newU);
        });
        if (widget.shouldPop) Navigator.of(context).pop();
      }
    }

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
                              avatar: const AIAvatar("Poly"),
                              child: Text(
                                e.msg,
                                textWidthBasis: TextWidthBasis.longestLine,
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
                              textWidthBasis: TextWidthBasis.longestLine,
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
                if (_offset == size.height) return;
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
                                : (_) {
                                    session.addUserMsg(_textController.text);
                                    _textController.clear();
                                  },
                            hintText: AppLocalizations.of(context)!
                                .chat_input_hint_reg)),
                    const SizedBox(width: 8),
                    SendButton(
                        onPressed: () {
                          session.addUserMsg(_textController.text);
                          _textController.clear();
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
