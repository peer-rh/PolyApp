import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/input_area.dart';
import 'package:poly_app/app/lessons/ai_chat/logic.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  bool modeIsAudio = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeChatSession);
    return Stack(
        
    );
  }
}

class KeyboardInput extends StatelessWidget {
  final void Function(String) onSend;
  final void Function() onAudio;
  final bool enabled;
  final ({String appLang, String learnLang})? suggestion;
  KeyboardInput(
      {required this.onSend,
      required this.onAudio,
      required this.suggestion,
      required this.enabled,
      super.key});

  final _cont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        InkWell(
            onTap: onAudio,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
                height: 32,
                width: 32,
                child: Icon(CustomIcons.chataudio,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.8),
                    size: 24))),
        const SizedBox(width: 8),
        Expanded(
            child: ChatTextField(
                trailing: suggestion == null
                    ? null
                    : CustomCircularButton(
                        outlineColor:
                            Theme.of(context).colorScheme.onBackground,
                        icon: const Icon(CustomIcons.questionmark, size: 16),
                        onPressed: () {
                          showSuggestion(context, suggestion!.appLang,
                              suggestion!.learnLang);
                        },
                        size: 24),
                controller: _cont,
                onSubmitted: (_) => onSend(_cont.text),
                hintText:
                    suggestion == null ? "Type here..." : "Try again...")),
        const SizedBox(width: 8),
        SendButton(onPressed: () => onSend(_cont.text), enabled: enabled),
      ]),
    );
  }
}

void showSuggestion(BuildContext context, String appLang, String learnLang) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text("Suggestion"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appLang, style: Theme.of(context).textTheme.bodyLarge),
            const Divider(),
            Text(learnLang, style: Theme.of(context).textTheme.bodyMedium)
          ],
        )),
  );
}
