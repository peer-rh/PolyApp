import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/lesson_model.dart';
final aiChatLessonProvider =
    FutureProvider.family<AiChatLessonModel, String>((ref, id) async {
  final doc =
      await FirebaseFirestore.instance.collection("lessons").doc(id).get();
  return AiChatLessonModel.fromJson(doc.data()!, id);
});
