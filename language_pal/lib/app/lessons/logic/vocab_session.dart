import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/lessons/data/input_step.dart';
import 'package:poly_app/app/lessons/data/vocab_lesson_model.dart';
import 'package:poly_app/app/lessons/logic/lesson_providers.dart';
import 'package:poly_app/app/lessons/logic/util.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/abilities.dart';

final activeVocabId = StateProvider<String?>((ref) => null);

final activeVocabSession = ChangeNotifierProvider<ActiveVocabSession?>((ref) {
  final learnId = ref.watch(activeVocabId);
  if (learnId == null) {
    return null;
  }
  final vocabLesson = ref.watch(vocabLessonProvider(learnId));
  final lesson = vocabLesson.asData?.value;
  final trackId = ref.watch(currentLearnTrackIdProvider);
  final uid = ref.watch(uidProvider);
  if (lesson == null || trackId == null || uid == null) {
    return null;
  }
  final out = ActiveVocabSession(lesson, uid);
  ref.listen(cantTalkProvider, (_, newVal) => out.cantTalk = newVal);
  ref.listen(cantListenProvider, (_, newVal) => out.cantListen = newVal);
  return out;
});

class ActiveVocabSession extends ChangeNotifier {
  final VocabLessonModel lesson;
  final String _uid;

  String? _currentAnswer;
  String get currentAnswer => _currentAnswer ?? "";

  bool _cantTalk = false;
  set cantTalk(bool newVal) {
    _cantTalk = newVal;
    notifyListeners();
  }

  bool _cantListen = false;
  set cantListen(bool newVal) {
    _cantListen = newVal;
    notifyListeners();
  }

  set currentAnswer(String? answer) {
    _currentAnswer = answer;
    notifyListeners();
  }

  List<InputStep> _steps = [];
  int? _currentStep;

  bool get finished => _currentStep == _steps.length;

  int get currentStepIndex => _currentStep ?? 0;
  InputStep? get currentStep {
    if (_currentStep == null || _currentStep! >= _steps.length) {
      return null;
    }
    if (_steps[_currentStep!].type == InputType.listen && _cantListen) {
      _steps[_currentStep!].type = InputType.select;
    } else if (_steps[_currentStep!].type == InputType.pronounce && _cantTalk) {
      _currentStep = _currentStep! + 1;
    }
    return _steps[_currentStep!];
  }

  ActiveVocabSession(this.lesson, this._uid) {
    _initState();
  }

  void _initState() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("lessons")
        .doc(lesson.id)
        .get();
    if (doc.exists) {
      final json = doc.data()!;
      _steps = await json['steps']
          .map<InputStep>((e) => InputStep.fromJson(e))
          .toList(growable: false);
      _currentStep = await json['currentStep'];
      notifyListeners();
    } else {
      _genProgram();
      notifyListeners();
    }
  }

  void _genProgram() {
    final stage_1 = [InputType.select, InputType.listen];
    final stage_2 = [InputType.compose, InputType.pronounce, InputType.write];
    List<List<VocabModel>> groups = [];
    for (int i = 0; i < lesson.vocabList.length; i += 4) {
      groups.add(
          lesson.vocabList.sublist(i, min(i + 4, lesson.vocabList.length)));
    }

    final random = Random();
    List<List<List<InputStep>>> stepsGrouped = [];

    List<String> allWords = [];
    for (VocabModel v in lesson.vocabList) {
      for (String s in v.learnLang.split(" ")) {
        allWords.add(s);
      }
    }

    InputStep? genInputStep(InputType type, VocabModel vocab) {
      switch (type) {
        case InputType.select:
          // TODO: Add Audio to options
          return InputStep(
              prompt: vocab.appLang,
              answer: vocab.learnLang,
              type: type,
              options: [
                vocab.learnLang,
                ...generateRandomIntegers(4, lesson.vocabList.length)
                    .map((e) => lesson.vocabList[e].learnLang)
                    .where((e) => e != vocab.learnLang)
                    .take(3)
                    .toList()
              ]);
        case InputType.listen:
          return InputStep(
            prompt: vocab.appLang,
            answer: vocab.learnLang,
            type: type,
            options: [
              vocab.learnLang,
              ...generateRandomIntegers(4, lesson.vocabList.length)
                  .map((e) => lesson.vocabList[e].learnLang)
                  .where((e) => e != vocab.learnLang)
                  .take(3)
                  .toList()
            ],
            audioUrl: vocab.audioUrl,
          );
        case InputType.compose:
          if (vocab.learnLang.split(" ").length == 1) return null;
          final correctOptions = vocab.learnLang.split(" ");
          return InputStep(
              prompt: vocab.appLang,
              answer: vocab.learnLang,
              type: type,
              options: [
                ...correctOptions,
                ...generateRandomIntegers(8, allWords.length)
                    .map((e) => allWords[e])
                    .where((e) => !correctOptions.contains(e))
                    .take(8)
                    .toList()
              ]);

        case InputType.pronounce:
          return InputStep(
            prompt: vocab.learnLang,
            answer: vocab.learnLang,
            type: type,
            audioUrl: vocab.audioUrl,
          );

        case InputType.write:
          return InputStep(
            prompt: vocab.appLang,
            answer: vocab.learnLang,
            type: type,
          );
      }
    }

    for (int i = 0; i < groups.length; i++) {
      stepsGrouped.add([[], [], []]);
      for (VocabModel v in groups[i]) {
        final s1I = random.nextInt(stage_1.length);
        final s2I = random.nextInt(stage_2.length);
        var s3I = random.nextInt(stage_2.length);
        if (s2I == s3I) {
          s3I = (s3I + 1) % stage_2.length;
        }
        stepsGrouped[i][0].add(genInputStep(stage_1[s1I], v)!);
        final s2 = genInputStep(stage_2[s2I], v);
        if (s2 != null) {
          stepsGrouped[i][1].add(s2);
        }
        final s3 = genInputStep(stage_2[s3I], v);
        if (s3 != null) {
          stepsGrouped[i][1].add(s3);
        }
      }
      stepsGrouped[i][1].shuffle();
      stepsGrouped[i][2].shuffle();
    }

    List<InputStep> steps = [];
    steps.addAll(stepsGrouped[0][0]);
    steps.addAll(stepsGrouped[0][1]);
    for (int i = 1; i < stepsGrouped.length; i++) {
      steps.addAll(stepsGrouped[i][0]);
      steps.addAll(stepsGrouped[i - 1][2]);
      steps.addAll(stepsGrouped[i][1]);
    }
    steps.addAll(stepsGrouped[stepsGrouped.length - 1][2]);

    _steps = steps;
    _currentStep = 0;
  }

  void saveState() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("lessons")
        .doc(lesson.id)
        .set({
      "steps": _steps.map((e) => e.toJson()).toList(),
      "currentStep": _currentStep! + 1,
    });
  }

  void submitAnswer() {
    // TODO: Add Error logging
    currentStep!.userAnswer = _currentAnswer;
    saveState();
    notifyListeners();
  }

  void nextStep() {
    _currentAnswer = null;
    _currentStep = _currentStep! + 1;
    notifyListeners();
  }
}
