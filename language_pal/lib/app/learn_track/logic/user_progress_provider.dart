import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';

final userLearnTrackDocProvider = Provider<DocumentReference>((ref) {
  final id = ref.watch(currentLearnTrackIdProvider);
  final uid = ref.watch(uidProvider);

  return FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("tracks")
      .doc("${id!.alCode}_${id.llCode}_${id.id}");
});

final userProgressProvider =
    ChangeNotifierProvider<UserProgressProvider>((ref) {
  final uid = ref.watch(uidProvider);
  final trackId = ref.watch(currentLearnTrackIdProvider);
  return UserProgressProvider(
      uid,
      trackId != null
          ? "${trackId.alCode}_${trackId.llCode}_${trackId.id}"
          : null);
});

class UserProgressProvider extends ChangeNotifier {
  final String? _uid;
  final String? _trackId;
  Map<String, String> _userMap = {};

  UserProgressProvider(this._uid, this._trackId) {
    _initState();
  }

  _initState() async {
    if (_uid == null || _trackId == null) {
      return;
    }
    FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("tracks")
        .doc(_trackId)
        .get()
        .then((value) {
      if (!value.exists) {
        _userMap = {};
      } else {
        _userMap = value.data()!["progress"].cast<String, String>();
        notifyListeners();
      }
    });
  }

  String? getStatus(String id) {
    /// this either returns the id of current step, "finished" or null (locked/skipped)
    return _userMap[id];
  }

  void setStatus(String id, String status) {
    /// "finished" if finished, else id of current step
    _userMap[id] = status;
    notifyListeners();
    FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("tracks")
        .doc(_trackId)
        .set({
      "progress": _userMap.map((key, value) => MapEntry(key, value)),
    });
  }
}
