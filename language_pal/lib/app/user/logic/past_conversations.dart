import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';

Future<List<Messages>> loadPastConversations(
    List<ScenarioModel> scenarios, String uid) async {
  // Get all docs in user/${uid}/conversations
  // For each doc, get the scenario and the messages
  // Return a list of Messages
  List<Messages> conversations = [];
  FirebaseFirestore.instance
      .collection('user')
      .doc(uid)
      .collection('conversations')
      .get()
      .then((value) {
    for (var element in value.docs) {
      final data = element.data();
      final scenario = scenarios
          .firstWhere((element) => element.uniqueId == data['scenario_id']);
      conversations.add(Messages.fromFirestore(data, scenario));
    }
  });
  return conversations;
}

Future<void> addConversationToFirestore(
    Messages conversation, String uid) async {
  // First check if already conv with id exists
  // Then check for the better rating and update
  // If no better rating, do nothing

  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .doc(conversation.scenario.uniqueId)
      .get()
      .then((value) {
    if (value.exists) {
      final data = value.data();
      final oldRating = data!['rating']!['rating'];
      if (oldRating < conversation.rating!.rating) {
        FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .collection('conversations')
            .doc(conversation.scenario.uniqueId)
            .set(conversation.toFirestore());
      }
    } else {
      FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('conversations')
          .doc(conversation.scenario.uniqueId)
          .set(conversation.toFirestore());
    }
  });
}
