import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/app/user/ui/onboarding.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/flag.dart';

void showLearnTrackOverlay(BuildContext context) {
  final overlayState = Overlay.of(context);
  OverlayEntry? overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return LearnTrackLayover(
        onDismiss: () {
          overlayEntry?.remove();
        },
      );
    },
  );
  overlayState.insert(overlayEntry);
}

class LearnTrackLayover extends ConsumerWidget {
  final void Function() onDismiss;
  const LearnTrackLayover({required this.onDismiss, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          ModalBarrier(onDismiss: onDismiss, color: Colors.black54),
          Positioned(
              top: AppBar().preferredSize.height + kToolbarHeight + 8,
              right: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: [
                    for (var e in ref
                        .watch(userProvider)!
                        .learnTrackList
                        .asMap()
                        .entries)
                      InkWell(
                          onTap: () => ref
                              .read(userProvider.notifier)
                              .setActiveLearnTrack(e.key),
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                              width: 64,
                              height: 48,
                              child: Flag(code: e.value.learnLang.code))),
                    InkWell(
                      onTap: () {
                        onDismiss();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const OnboardingPage(
                                  shouldPop: true,
                                )));
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        width: 64,
                        height: 48,
                        child: Icon(
                          CustomIcons.pluscircle,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 32,
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
