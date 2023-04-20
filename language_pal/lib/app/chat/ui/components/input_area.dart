import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/app/chat/features/get_answer_suggestion.dart';
import 'package:language_pal/app/chat/logic/conversation_provider.dart';
import 'package:language_pal/common/data/scenario_model.dart';
import 'package:language_pal/common/logic/languages.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatInputArea extends ConsumerStatefulWidget {
  ScenarioModel scenario;

  ChatInputArea({Key? key, required this.scenario}) : super(key: key);

  @override
  ConsumerState<ChatInputArea> createState() => _InputAreaState();
}

class _InputAreaState extends ConsumerState<ChatInputArea> {
  final _controller = TextEditingController();
  bool _speechEnabled = false;
  bool _listening = false;
  SendButtonState _sendButtonState = SendButtonState.mic;
  final _speechToText = SpeechToText();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initSpeech();
    super.initState();
    _controller.addListener(() {
      setButtonState();
    });
  }

  void setButtonState() {
    if (_listening) {
      _sendButtonState = SendButtonState.micListening;
    } else if (_controller.text.isEmpty && _speechEnabled) {
      _sendButtonState = SendButtonState.mic;
    } else {
      _sendButtonState = SendButtonState.send;
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) {
      // TODO: Show error message
      return;
    }
    await _speechToText.listen(
        listenMode: ListenMode.dictation,
        onResult: _onSpeechResult,
        localeId: ref
            .read(conversationProvider(widget.scenario))
            .learnLang
            .speechRecognitionLocale);
    _listening = true;
    setButtonState();
  }

  void _stopListening() async {
    await _speechToText.stop();
    _listening = false;
    setButtonState();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _controller.text = result.recognizedWords;
      if (result.finalResult) _stopListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    ConversationProvider conv =
        ref.watch(conversationProvider(widget.scenario));
    bool disabled = !(conv.status == ConversationStatus.waitingForUserRedo ||
        conv.status == ConversationStatus.waitingForUser);
    String hint = _listening
        ? AppLocalizations.of(context)!.chat_input_hint_listening
        : conv.status == ConversationStatus.waitingForUserRedo
            ? AppLocalizations.of(context)!.chat_input_hint_try_again
            : AppLocalizations.of(context)!.chat_input_hint_reg;
    IconData icon;
    switch (_sendButtonState) {
      case SendButtonState.mic:
        icon = Icons.mic;
        break;
      case SendButtonState.micListening:
        icon = Icons.mic_none;
        break;
      case SendButtonState.send:
        icon = Icons.send;
        break;
    }
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
                        conv.addPersonMsg(_controller.text);
                        _controller.text = "";
                      }
                    },
                    controller: _controller,
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
                if (conv.status == ConversationStatus.waitingForUserRedo)
                  AnswerSuggestionButton(conv)
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          height: 50,
          width: 50,
          child: IconButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(disabled
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Theme.of(context).colorScheme.primary),
            ),
            onPressed: (disabled)
                ? null
                : () async {
                    switch (_sendButtonState) {
                      case SendButtonState.send:
                        conv.addPersonMsg(_controller.text);
                        _controller.text = "";
                        break;
                      case SendButtonState.mic:
                        _startListening();
                        HapticFeedback.lightImpact();
                        break;
                      case SendButtonState.micListening:
                        _stopListening();
                    }
                  },
            icon: Icon(
              icon,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

enum SendButtonState {
  send,
  mic,
  micListening,
}
