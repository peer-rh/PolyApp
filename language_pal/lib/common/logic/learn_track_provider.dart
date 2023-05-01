import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/data/learn_track_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentLearnTrackProvider =
    StateNotifierProvider<CurrentLearnTrackNotifier, LearnTrackModel?>((ref) {
  final uid = ref.watch(uidProvider);
  return CurrentLearnTrackNotifier(uid);
});

class CurrentLearnTrackNotifier extends StateNotifier<LearnTrackModel?> {
  final String? uid;
  String? _trackId;
  Map<String, PartStatus> _userMap = {};

  CurrentLearnTrackNotifier(this.uid) : super(null) {
    _initState();
  }

  _initState() async {
    if (uid == null) return;
    await _loadTrackId();
    _loadData();
  }

  Future<void> _loadTrackId() async {
    if (uid == null) return;
    _trackId = (await SharedPreferences.getInstance()).getString("track_id");
  }

  void _loadData() async {
    if (_trackId == null || uid == null) return;
    state = LearnTrackModel.fromMap(
        json.decode(FirebaseRemoteConfig.instance.getString(_trackId!)));
    FirebaseFirestore.instance
        .collection("users")
        .doc("uid")
        .collection("learn_tracks")
        .doc(_trackId)
        .get()
        .then((value) {
      if (!value.exists) {
        _userMap = {};
      } else {
        _userMap = value
            .data()!
            .map((key, value) => MapEntry(key, PartStatus.fromCode(value)));
      }
    });
  }

  String? get trackId => _trackId;
  void setLearnTrackId(String id) {
    _trackId = id;
    _loadData();
  }

  PartStatus getProgress(String id) {
    return _userMap[id] ?? PartStatus.locked;
  }

  void setProgress(String id, PartStatus status) {
    _userMap[id] = status;
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("learn_tracks")
        .doc(_trackId)
        .set(_userMap.map((key, value) => MapEntry(key, value.code)));
  }
}
