import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final reminderProvider =
    StateNotifierProvider<ReminderProvider, List<int>>((ref) {
  return ReminderProvider();
});

class ReminderProvider extends StateNotifier<List<int>> {
  ReminderProvider() : super([]) {
    _load();
  }

  void _load() async {
    final sp = await SharedPreferences.getInstance();
    state =
        sp.getStringList("reminder")?.map((e) => int.parse(e)).toList() ?? [];
  }

  void _save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setStringList("reminder", state.map((e) => e.toString()).toList());
  }

  void removeDay(int day) {
    if (!state.contains(day)) return;
    FirebaseMessaging.instance.unsubscribeFromTopic("reminder_$day");
    state = state.where((element) => element != day).toList();
    _save();
  }

  void addDay(int day) {
    if (state.contains(day)) return;
    FirebaseMessaging.instance.subscribeToTopic("reminder_$day");
    state = [...state, day];
    _save();
  }

}
