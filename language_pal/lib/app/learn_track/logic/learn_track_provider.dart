import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/learn_track_model.dart';
import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/languages.dart';

final currentLearnTrackIdProvider = Provider<LearnTrackId?>((ref) {
  final up = ref.watch(userProvider);
  return up?.activeLearnTrack;
});

final currentLearnTrackProvider = FutureProvider<LearnTrackModel?>((ref) async {
  final id = ref.watch(currentLearnTrackIdProvider);
  if (id == null) return null;

  final staticDoc = ref.watch(staticFirestoreDoc);

  final doc = await staticDoc.collection("learn_tracks").doc(id.id).get();
  return LearnTrackModel.fromJson(doc.data()!, id.id);
});

final subchapterProvider =
    FutureProvider.family<SubchapterModel, String>((ref, id) async {
  final staticDoc = ref.watch(staticFirestoreDoc);
  final doc = await staticDoc.collection("subchapters").doc(id).get();
  return SubchapterModel.fromJson(doc.data()!, id);
});
