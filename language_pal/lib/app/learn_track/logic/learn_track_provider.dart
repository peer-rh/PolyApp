import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/learn_track_model.dart';
import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentLearnTrackIdProvider = Provider<LearnTrackId?>((ref) {
  final up = ref.watch(userProvider);
  return up?.activeLearnTrack;
});

final currentLearnTrackProvider = FutureProvider<LearnTrackModel?>((ref) async {
  final id = ref.watch(currentLearnTrackIdProvider);
  if (id == null) return null;

  final static_doc = ref.watch(staticFirestoreDoc);

  final doc = await static_doc.collection("learn_tracks").doc(id.id).get();
  return LearnTrackModel.fromJson(doc.data()!, id.id);
});

final subchapterProvider =
    FutureProvider.family<SubchapterModel, String>((ref, id) async {
  final static_doc = ref.watch(staticFirestoreDoc);
  final doc = await static_doc.collection("subchapters").doc(id).get();
  return SubchapterModel.fromJson(doc.data()!, id);
});
