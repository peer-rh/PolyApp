import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/models/user_model.dart';

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
          .firstWhere((element) => element.uniqueId == data['scenario']);
      conversations.add(Messages.fromFirestore(data, scenario));
    }
  });
  return conversations;
}

Future<void> addConversationToFirestore(
    Messages conversation, AuthProvider ap) async {
  if (ap.user!.scenarioScores.containsKey(conversation.scenario.uniqueId) &&
      ap.user!.scenarioScores[conversation.scenario.uniqueId]! <=
          conversation.rating!.score!) {
    UserModel newUser = ap.user!;
    newUser.scenarioScores[conversation.scenario.uniqueId] =
        conversation.rating!.score!;
    ap.setUserModel(newUser);
  }

  final uid = ap.firebaseUser!.uid;

  FirebaseFirestore.instance
      .collection('user')
      .doc(uid)
      .collection('conversations')
      .add(conversation.toFirestore());
}
