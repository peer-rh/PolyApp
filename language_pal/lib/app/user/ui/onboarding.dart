import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat/data/conversation.dart';
import 'package:poly_app/app/chat/data/messages.dart';
import 'package:poly_app/app/chat/ui/components/chat_bubble.dart';
import 'package:poly_app/app/chat/ui/components/conv_column.dart';
import 'package:poly_app/app/chat/ui/components/input_area.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/user/data/user_model.dart';
import 'package:poly_app/app/user/logic/get_onboarding_response.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';
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
  UserModel thisUser = UserModel("", "", [], "");
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _enabled = true;
  bool _loading = false;
  double _offset = 0;
  final _conv =
      Conversation("onboarding", "en"); // TODO: Set to user's language

  @override
  void didChangeDependencies() async {
    thisUser.uid = ref.read(authProvider).currentUser!.uid;
    thisUser.email = ref.read(authProvider).currentUser!.email ?? "";
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _conv.addMsg(AIMsgModel(
        "Hello I'm Poly, your language learning assistant. Great to hear, that you are interested in learning a new language. What Language would you like to learn?")); // TODO: Localize
    setState(() {});
    super.initState();
  }

  void onSubmit() {
    // TODO: Add Msg when there is an error in parsing
    // TODO: Add Animation to next screen
    setState(() {
      _conv.addMsg(
          PersonMsgListModel([SingularPersonMsgModel(_textController.text)]));
      _textController.clear();
      _enabled = false;
      _loading = true;
    });
    getAIOnboardingResponse(_conv).then((value) {
      _conv.addMsg(AIMsgModel(value.message));
      _loading = false;
      if (value.language != null) {
        // TODO: Maybe add Alert
        // TODO: Add AppLang
        thisUser.learnTrackList = [
          "${value.useCase!.code}_en_${value.language!.code}"
        ];
        ref.read(currentLearnTrackIdProvider.notifier).state =
            thisUser.learnTrackList[0];
        ref.read(userProvider.notifier).setUserModel(thisUser);
      } else {
        _enabled = true;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FrostedAppBar(title: const Text("Welcome")), // TODO: Localize
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
                    ConversationColumnOld(
                      conv: _conv,
                      aiAvatar: "assets/avatars/Poly.png",
                    ),
                    _loading
                        ? const AIMsgBubbleLoading("assets/avatars/Poly.png")
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
                            onSubmitted: (_) => onSubmit(),
                            hintText: AppLocalizations.of(context)!
                                .chat_input_hint_reg)),
                    const SizedBox(width: 8),
                    SendButton(
                        onPressed: () {
                          onSubmit();
                        },
                        enabled: _enabled)
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
