import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/vocab/logic.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';

final userErrorProvider = ChangeNotifierProvider<UserErrorProvider>((ref) {
  final uid = ref.watch(uidProvider);
  final userTrackDoc = ref.watch(userLearnTrackDocProvider);
  final err = UserErrorProvider(uid!, userTrackDoc);

  ref.listen(activeVocabSession, (previous, next) {
    if (next?.currentStep?.isCorrect == false &&
        previous?.currentStep?.isCorrect != null) {
      err.addError(next!.currentStep!);
    }
  });
  return err;
});

class UserErrorProvider extends ChangeNotifier {
  String uid;
  final DocumentReference userTrackDoc;
  List<InputStep> _steps = [];

  List<InputStep> get steps => _steps;

  UserErrorProvider(this.uid, this.userTrackDoc) {
    _initState();
  }

  InputStep? get currentStep => _steps.isEmpty ? null : _steps.first;

  void _initState() async {
    final doc = await userTrackDoc.collection("errors").doc("vocab").get();
    if (doc.data() != null) {
      _steps = (doc.data()!["steps"] as List)
          .map((e) => InputStep.fromJson(e))
          .toList();
      _steps.shuffle();
    }
    notifyListeners();
  }

  void addError(InputStep step) {
    final tmp = step.copy();
    tmp.userAnswer = null;
    _steps.add(tmp);
    _steps.shuffle();
    _saveState();
  }

  void _saveState() {
    notifyListeners();
    userTrackDoc
        .collection("errors")
        .doc("vocab")
        .set({"steps": _steps.map((e) => e.toJson()).toList()});
  }

  void submitAnswer(String answer) {
    currentStep!.userAnswer = answer;
    notifyListeners();
  }

  void nextStep() {
    final tmp = _steps.removeAt(0);
    if (!tmp.isCorrect!) {
      tmp.userAnswer = null;
      _steps.add(tmp);
    }
    _saveState();
  }
}
