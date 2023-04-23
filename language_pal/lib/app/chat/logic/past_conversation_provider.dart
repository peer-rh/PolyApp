import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/chat/data/conversation.dart';
import 'package:language_pal/app/user/logic/learn_language_provider.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';

final pastConversationProvider =
    StateNotifierProvider<PastConversationProvider, List<Conversation>>((ref) {
  final uid = ref.watch(uidProvider) ?? "";
  final learnLang = ref.watch(learnLangProvider).code;
  return PastConversationProvider(uid, learnLang);
});

final bestScoreProvider =
    StateNotifierProvider<BestScoreProvider, Map<String, int>>((ref) {
  final uid = ref.watch(uidProvider) ?? "";
  final learnLang = ref.watch(learnLangProvider).code;
  return BestScoreProvider(uid, learnLang);
});

class PastConversationProvider extends StateNotifier<List<Conversation>> {
  final String uid;
  bool loading = true;
  final String learnLang;

  PastConversationProvider(this.uid, this.learnLang) : super([]) {
    _loadPastConversations(uid, learnLang);
  }

  void _loadPastConversations(String uid, String learnLang) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection(learnLang)
        .get()
        .then((value) {
      loading = false;
      state =
          value.docs.map((e) => Conversation.fromFirestore(e.data())).toList();
    });
  }

  void addConversation(Conversation conv) {
    state.add(conv);
    _saveConversation(conv);
  }

  void _saveConversation(Conversation conv) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection(learnLang)
        .add(conv.toFirestore());
  }
}

class BestScoreProvider extends StateNotifier<Map<String, int>> {
  final String uid;
  final String learnLang;

  BestScoreProvider(this.uid, this.learnLang) : super({}) {
    _loadBestScores(uid, learnLang);
  }

  void _loadBestScores(String uid, String learnLang) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("best_scores")
        .doc(learnLang)
        .get()
        .then((value) {
      if (value.exists) {
        state = value.data() as Map<String, int>;
      }
    });
  }

  void updateBestScore(String scenarioId, int score) {
    if (state[scenarioId] == null || state[scenarioId]! < score) {
      state[scenarioId] = score;
      _saveBestScore(scenarioId, score);
    }
  }

  void _saveBestScore(String scenarioId, int score) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("best_scores")
        .doc(learnLang)
        .set({scenarioId: score}, SetOptions(merge: true));
  }
}
