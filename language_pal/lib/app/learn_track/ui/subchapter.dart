import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/learn_track/ui/components/list_item.dart';
import 'package:poly_app/app/lessons/ai_chat/logic.dart';
import 'package:poly_app/app/lessons/ai_chat/ui.dart';
import 'package:poly_app/app/lessons/mock_chat/logic.dart';
import 'package:poly_app/app/lessons/mock_chat/ui.dart';
import 'package:poly_app/app/lessons/vocab/logic.dart';
import 'package:poly_app/app/lessons/vocab/ui.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class SubchapterPage extends ConsumerStatefulWidget {
  final String id;
  final String? nextSubchapterTitle;
  final void Function(BuildContext)? onNextSubchapter;
  final void Function() onFinished;
  const SubchapterPage(this.id, this.onFinished,
      {this.onNextSubchapter, this.nextSubchapterTitle, Key? key})
      : super(key: key);

  @override
  _SubchapterPageState createState() => _SubchapterPageState();
}

class _SubchapterPageState extends ConsumerState<SubchapterPage> {
  SubchapterModel? subchapter;

  IconData getLessonIcon(String type) {
    switch (type) {
      case "vocab":
        return CustomIcons.book;
      case "mock_chat":
        return CustomIcons.chatcheck;
      case "ai_chat":
        return CustomIcons.chattext;
      default:
        throw Exception("Unknown lesson type: $type");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProgress = ref.watch(userProgressProvider);
    ref.watch(subchapterProvider(widget.id)).when(
        data: (data) => setState(() {
              subchapter = data;
            }),
        error: (err, _) => print(err),
        loading: () {});

    if (subchapter == null) {
      return const LoadingPage();
    }

    void goToLesson(int i) {
      final lesson = subchapter!.lessons[i];
      onFinished() {
        print("onFinished");
        Future(() {
          ref.read(userProgressProvider).setStatus(subchapter!.id, lesson.id);
        });
      }

      final next = i + 1 < subchapter!.lessons.length
          ? subchapter!.lessons[i + 1]
          : null;
      final nextTitle = next?.title ?? "Next Subchapter";
      final onNext = next == null
          ? (BuildContext context) {
              Navigator.pop(context);
            }
          : (BuildContext context) {
              Navigator.pop(context);
              goToLesson(i + 1);
            };
      if (lesson.type == "vocab") {
        ref.read(activeVocabId.notifier).state = lesson.id;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VocabPage(
                    onFinished: onFinished,
                    onNextStep: onNext,
                    nextStepTitle: nextTitle,
                  )),
        );
      } else if (lesson.type == "mock_chat") {
        ref.read(activeMockChatId.notifier).state = lesson.id;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MockChatPage(
                onFinished: onFinished,
                onNextStep: onNext,
                nextStepTitle: nextTitle,
              ),
            ));
      } else if (lesson.type == "ai_chat") {
        ref.read(activeChatId.notifier).state = lesson.id;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatPage(
                  onFinished: onFinished,
                  onNextStep: onNext,
                  nextStepTitle: nextTitle,
                )));
      }
    }

    List<Widget> itemList = [];
    bool done = userProgress.getStatus(subchapter!.id) != null;
    bool inProgress = !done;
    for (var i = 0;
        i <
            subchapter!.lessons.length * 2 -
                (widget.nextSubchapterTitle == null ? 1 : 0);
        i++) {
      if (i % 2 == 0) {
        final lesson = subchapter!.lessons[i ~/ 2];
        itemList.add(ListItem(
            enabled: done || inProgress,
            highlighted: inProgress,
            title: Text(lesson.title,
                style: Theme.of(context).textTheme.titleSmall),
            icon: getLessonIcon(lesson.type),
            onTap: done || inProgress || kDebugMode // TODO: Remove debug mode
                ? () {
                    goToLesson(i ~/ 2);
                  }
                : null));
        if (lesson.id == userProgress.getStatus(subchapter!.id)) {
          done = false;
          inProgress = true;
        } else {
          inProgress = false;
        }
      } else {
        itemList.add(Container(
            alignment: Alignment.centerLeft,
            child: Container(
                width: 2,
                height: 16,
                color: !done
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary,
                margin: const EdgeInsets.only(top: 4, bottom: 4, left: 28))));
      }
    }
    if (widget.nextSubchapterTitle != null) {
      itemList.add(ListItem(
          enabled: inProgress,
          highlighted: inProgress,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Up Next:",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                widget.nextSubchapterTitle!,
                style: Theme.of(context).textTheme.titleSmall,
              )
            ],
          ),
          icon: inProgress ? CustomIcons.lockopen : CustomIcons.lock,
          onTap: inProgress
              ? () {
                  widget.onNextSubchapter!(context);
                }
              : null));
    }

    if (done) {
      widget.onFinished();
    }
    return Scaffold(
        appBar: const FrostedAppBar(title: SizedBox()),
        extendBodyBehindAppBar: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              Text(subchapter!.title,
                  style: Theme.of(context).textTheme.displayLarge),
              Text(subchapter!.description,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6))),
              const SizedBox(height: 24),
              ...itemList,

              // TODO: Skip to next subchapter
            ],
          ),
        ));
  }
}
