import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/chat/data/conversation.dart';

final pastConversationProvider =
    StreamProvider.family<List<Conversation>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .snapshots()
      .map((event) {
    return event.docs
        .map((element) => Conversation.fromFirestore(element.data()))
        .toList();
  });
});

void saveConvToFirestore(String uid, Conversation conv) async {
  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .add(conv.toFirestore());
}
