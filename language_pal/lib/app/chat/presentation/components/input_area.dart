import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/chat/logic/get_answer_suggestion.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/common/languages.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatInputArea extends StatefulWidget {
  void Function(String, bool) sendMsg;
  Conversation conv;

  ChatInputArea({Key? key, required this.sendMsg, required this.conv})
      : super(key: key);

  @override
  State<ChatInputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<ChatInputArea> {
  final controller = TextEditingController();
  var microphoneOn = true;
  var _speechEnabled = false;
  final _speechToText = SpeechToText();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initSpeech();
    super.initState();
    controller.addListener(() {
      setState(() {
        microphoneOn = _speechEnabled && controller.text.isEmpty;
      });
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
        listenMode: ListenMode.dictation,
        onResult: _onSpeechResult,
        localeId: convertLangCode(widget.conv.scenario.learnLang)
            .getSpeechRecognitionLocale());
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      controller.text = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool disabled = widget.conv.state != ConversationState.waitingForUserMsg &&
        widget.conv.state != ConversationState.waitingForUserRedo;
    String hint = widget.conv.state == ConversationState.waitingForUserRedo
        ? AppLocalizations.of(context)!.chat_input_hint_try_again
        : AppLocalizations.of(context)!.chat_input_hint_reg;
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceVariant),
                color: Theme.of(context).colorScheme.surface),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: TextField(
                    autocorrect: false,
                    onSubmitted: (s) {
                      if (disabled) return;
                      if (s != "") {
                        widget.sendMsg(controller.text, true);
                        controller.text = "";
                      }
                    },
                    controller: controller,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                if (widget.conv.state == ConversationState.waitingForUserRedo)
                  AnswerSuggestionButton(widget.conv, widget.sendMsg)
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        InkWell(
          onLongPress: () {},
          customBorder: const CircleBorder(),
          child: GestureDetector(
            onTap: (microphoneOn || disabled)
                ? null
                : () async {
                    widget.sendMsg(controller.text, true);
                    controller.text = "";
                  },
            onLongPressStart: (!microphoneOn || disabled)
                ? null
                : (details) async {
                    _startListening();
                  },
            onLongPressEnd: (details) async {
              _stopListening();
            },
            child: Ink(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: disabled
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : Theme.of(context).colorScheme.primary),
              child: Align(
                alignment: Alignment.center,
                child: microphoneOn
                    ? FaIcon(
                        FontAwesomeIcons.microphone,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : FaIcon(
                        FontAwesomeIcons.arrowUp,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
