import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/learn_track_model.dart';
import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentLearnTrackIdProvider =
    StateNotifierProvider<CurrentLearnTrackIdNotif, String?>((ref) {
  return CurrentLearnTrackIdNotif();
});

class CurrentLearnTrackIdNotif extends StateNotifier<String?> {
  CurrentLearnTrackIdNotif() : super(null) {
    _initState();
  }

  @override
  set state(String? value) {
    super.state = value;
    if (value != null) {
      SharedPreferences.getInstance().then((sp) {
        sp.setString("track_id", value);
      });
    }
  }

  _initState() async {
    final id = await SharedPreferences.getInstance()
        .then((value) => value.getString("track_id"));
    if (id != null) {
      state = id;
    }
  }
}

final currentLearnTrackProvider = FutureProvider<LearnTrackModel?>((ref) async {
  final id = ref.watch(currentLearnTrackIdProvider);
  if (id == null) return null;

  final doc =
      await FirebaseFirestore.instance.collection("learn_tracks").doc(id).get();
  return LearnTrackModel.fromJson(doc.data()!, id);
});

final subchapterProvider =
    FutureProvider.family<SubchapterModel, String>((ref, id) async {
  final doc =
      await FirebaseFirestore.instance.collection("subchapters").doc(id).get();
  return SubchapterModel.fromJson(doc.data()!, id);
});
