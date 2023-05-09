import 'package:flutter_riverpod/flutter_riverpod.dart';

final cantTalkProvider = StateNotifierProvider<DelayedNotifier, bool>(
    (ref) => DelayedNotifier(const Duration(minutes: 15)));

final cantListenProvider = StateNotifierProvider<DelayedNotifier, bool>(
    (ref) => DelayedNotifier(const Duration(minutes: 15)));

class DelayedNotifier extends StateNotifier<bool> {
  final Duration delay;
  DelayedNotifier(this.delay) : super(false);

  void setOn() async {
    state = true;
    await Future.delayed(delay, () => state = false);
  }
}
