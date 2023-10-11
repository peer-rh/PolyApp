import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';

typedef CustomSubchapter = ({String id, String name});

final userLearnTrackDocProvider =
    Provider<DocumentReference<Map<String, dynamic>>>((ref) {
  final id = ref.watch(currentLearnTrackIdProvider);
  final uid = ref.watch(uidProvider);

  return FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("tracks")
      .doc("${id!.alCode}_${id.llCode}_${id.id}");
});

final userLearnTrackProvider =
    ChangeNotifierProvider<UserLearnTrackProvider>((ref) {
  return UserLearnTrackProvider(ref.watch(userLearnTrackDocProvider));
});

class UserLearnTrackProvider extends ChangeNotifier {
  final DocumentReference<Map<String, dynamic>> _trackDoc;
  Map<String, String> _userMap = {};
  List<CustomSubchapter> _customSubchapters = [];
  List<CustomSubchapter> get customSubchapters => _customSubchapters;

  UserLearnTrackProvider(this._trackDoc) {
    _initState();
  }

  _initState() async {
    _trackDoc.get().then((value) {
      if (!value.exists) {
        _userMap = {};
      } else {
        _userMap = (value.data()!["progress"] ?? {}).cast<String, String>();

        _customSubchapters = (value.data()!["customSubchapters"] ?? [])
            .map<CustomSubchapter>(
                (e) => (id: e["id"] as String, name: e["name"] as String))
            .toList();
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
    _trackDoc.set({
      "progress": _userMap.map((key, value) => MapEntry(key, value)),
    });
  }

  void addSubchapter(CustomSubchapter sub) {
    _customSubchapters.add(sub);
    notifyListeners();
    _trackDoc.set({
      "customSubchapters":
          _customSubchapters.map((e) => {"id": e.id, "name": e.name}).toList(),
    });
  }
}
