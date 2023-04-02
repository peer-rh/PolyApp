import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/models/user_model.dart';

Future<List<Conversation>> loadPastConversations(
    List<ScenarioModel> scenarios, String uid) async {
  List<Conversation> conversations = [];
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .get()
      .then((value) {
    for (var element in value.docs) {
      final data = element.data();
      final scenario = scenarios
          .firstWhere((element) => element.uniqueId == data['scenario']);
      conversations.add(Conversation.fromFirestore(data, scenario));
    }
  });
  return conversations;
}

Future<void> addConversationToFirestore(
    Conversation conversation, AuthProvider ap) async {
  if (!ap.user!.scenarioScores.containsKey(conversation.scenario.uniqueId) ||
      ap.user!.scenarioScores[conversation.scenario.uniqueId]! <=
          conversation.rating!.totalScore) {
    UserModel newUser = ap.user!;
    newUser.scenarioScores[conversation.scenario.uniqueId] =
        conversation.rating!.totalScore;
    ap.setUserModel(newUser);
  }

  final uid = ap.firebaseUser!.uid;

  FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .add(conversation.toFirestore());
}
