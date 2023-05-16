import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/learn_track_model.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/learn_track/ui/components/list_item.dart';
import 'package:poly_app/app/learn_track/ui/subchapter.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class LearnTrackPage extends ConsumerStatefulWidget {
  const LearnTrackPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LearnTrackPage> createState() => _LearnTrackPageState();
}

class _LearnTrackPageState extends ConsumerState<LearnTrackPage> {
  LearnTrackModel? learnTrack;

  @override
  Widget build(BuildContext context) {
    ref.watch(currentLearnTrackProvider).when(
        data: (data) {
          setState(() {
            learnTrack = data;
          });
        },
        error: (_, __) {},
        loading: () {});
    final userProgress = ref.watch(userProgressProvider);
    if (learnTrack == null) {
      return const LoadingPage();
    }
    List<Widget> itemList = [];
    bool done = userProgress.getStatus(learnTrack!.id) != null;
    bool inProgress = !done;
    for (var chap in learnTrack!.chapters) {
      itemList.add(
        Text(chap.title, style: Theme.of(context).textTheme.headlineLarge),
      );
      itemList.add(
        const SizedBox(height: 8),
      );
      for (var i = 0; i < chap.subchapters.length * 2 - 1; i++) {
        if (i % 2 == 0) {
          final subchap = chap.subchapters[i ~/ 2];
          itemList.add(ListItem(
            enabled: done || inProgress,
            title: subchap.title,
            highlighted: inProgress,
            icon: getChapterIcon(!(done || inProgress)),
            onTap: inProgress || done || kDebugMode
                ? () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SubchapterPage(subchap.id, () {
                              userProgress.setStatus(
                                  learnTrack!.id, subchap.id);
                            })));
                  }
                : null,
          ));
          if (subchap.id == userProgress.getStatus(learnTrack!.id)) {
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
                  color: done
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  margin: const EdgeInsets.only(top: 4, bottom: 4, left: 28))));
        }
      }
      itemList.add(const SizedBox(height: 32));
    }
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: FrostedAppBar(
          title: const SizedBox(),
          action: Container(
            margin: const EdgeInsets.only(right: 24),
            alignment: Alignment.centerLeft,
            child: Container(
              height: 32,
              width: 42,
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ), // TODO: Show chapter when scrolled down
        // TODO: Make Action be Button / Flag
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              children: itemList,
            )));
  }
}

IconData getChapterIcon(bool locked) {
  return switch (locked) {
    true => CustomIcons.lock,
    false => CustomIcons.check
  };
}
