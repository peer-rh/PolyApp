import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/chat/data/conversation.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';

final pastConversationProvider = StreamProvider<List<Conversation>>((ref) {
  final uid = ref.watch(userProvider).user?.uid;
  if (uid == null) {
    return const Stream.empty();
  }
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
