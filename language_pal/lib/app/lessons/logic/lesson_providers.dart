import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/lessons/data/mock_chat_lesson_model.dart';
import 'package:poly_app/app/lessons/data/vocab_lesson_model.dart';

final vocabLessonProvider =
    FutureProvider.family<VocabLessonModel, String>((ref, id) async {
  final doc =
      await FirebaseFirestore.instance.collection("lessons").doc(id).get();
  return VocabLessonModel.fromJson(doc.data()!, id);
});

final mockChatLessonProvider =
    FutureProvider.family<MockChatLessonModel, String>((ref, id) async {
  final doc =
      await FirebaseFirestore.instance.collection("lessons").doc(id).get();
  return MockChatLessonModel.fromJson(doc.data()!, id);
});
