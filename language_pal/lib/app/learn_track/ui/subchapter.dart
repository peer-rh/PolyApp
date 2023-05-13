import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/status.dart';
import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/learn_track/ui/components/list_item.dart';
import 'package:poly_app/app/lessons/logic/vocab_session.dart';
import 'package:poly_app/app/lessons/ui/vocab.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class SubchapterPage extends ConsumerStatefulWidget {
  final String id;

  const SubchapterPage(this.id, {Key? key}) : super(key: key);

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

  void ensureFirstLessonInProgress() {
    final userProgress = ref.read(userProgressProvider);
    if (userProgress.getStatus(subchapter!.lessons[0].id) ==
        UserProgressStatus.notStarted) {
      userProgress.setStatus(
          subchapter!.lessons[0].id, UserProgressStatus.inProgress);
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
    ensureFirstLessonInProgress();
    List<Widget> itemList = [];
    for (var i = 0; i < subchapter!.lessons.length * 2 - 1; i++) {
      if (i % 2 == 0) {
        final lesson = subchapter!.lessons[i ~/ 2];
        itemList.add(ListItem(
            enabled: userProgress.getStatus(lesson.id) !=
                UserProgressStatus.notStarted,
            highlighted: userProgress.getStatus(lesson.id) ==
                UserProgressStatus.inProgress,
            title: lesson.title,
            icon: getLessonIcon(lesson.type),
            onTap: () {
              if (lesson.type == "vocab") {
                ref.read(activeVocabId.notifier).state = lesson.id;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VocabPage()),
                );
              }
            }));
      } else {
        final isNotPrimary =
            userProgress.getStatus(subchapter!.lessons[i ~/ 2].id) ==
                    UserProgressStatus.notStarted ||
                userProgress.getStatus(subchapter!.lessons[i ~/ 2 + 1].id) ==
                    UserProgressStatus.notStarted;
        itemList.add(Container(
            alignment: Alignment.centerLeft,
            child: Container(
                width: 2,
                height: 16,
                color: isNotPrimary
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary,
                margin: const EdgeInsets.only(top: 4, bottom: 4, left: 28))));
      }
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
