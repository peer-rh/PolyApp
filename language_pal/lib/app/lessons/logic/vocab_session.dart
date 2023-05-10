import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/lessons/data/vocab_lesson_model.dart';
import 'package:poly_app/app/lessons/logic/lesson_providers.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/abilities.dart';

final activeVocabSession =
    ChangeNotifierProvider.family<ActiveVocabSession?, String>((ref, id) {
  final vocabLesson = ref.watch(vocabLessonProvider(id));
  final lesson = vocabLesson.value;
  final trackId = ref.watch(currentLearnTrackIdProvider);
  final uid = ref.watch(uidProvider);
  if (lesson == null || trackId == null || uid == null) {
    return null;
  }
  final out = ActiveVocabSession(trackId, lesson, uid);
  ref.listen(cantTalkProvider, (_, newVal) => out.cantTalk = newVal);
  ref.listen(cantListenProvider, (_, newVal) => out.cantListen = newVal);
  return out;
});

class ActiveVocabSession extends ChangeNotifier {
  final String _trackId;
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

  List<VocabStep> _steps = [];
  int? _currentStep;

  int get currentStepIndex => _currentStep ?? 0;
  VocabStep? get currentStep {
    if (_currentStep == null) {
      return null;
    }
    if (_steps[_currentStep!].type == VocabStepType.listen && _cantListen) {
      _steps[_currentStep!].type = VocabStepType.select;
    } else if (_steps[_currentStep!].type == VocabStepType.pronounce &&
        _cantTalk) {
      _currentStep = _currentStep! + 1;
    }
    return _steps[_currentStep!];
  }

  ActiveVocabSession(this._trackId, this.lesson, this._uid) {
    _initState();
  }

  void _initState() async {
    cacheAudio(); // TODO: See if actually faster
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("lessons")
        .doc(lesson.id)
        .get();
    if (doc.exists) {
      final json = doc.data()!;
      _steps = json['steps']
          .map<VocabStep>((e) => VocabStep.fromJson(e))
          .toList(growable: false);
      _currentStep = json['currentStep'];
    } else {
      _genProgram();
    }
    notifyListeners();
  }

  void _genProgram() {
    final stage_1 = [VocabStepType.select, VocabStepType.listen];
    final stage_2 = [
      VocabStepType.compose,
      VocabStepType.pronounce,
      VocabStepType.write
    ];
    List<List<VocabModel>> groups = [];
    for (int i = 0; i < lesson.vocabList.length; i += 4) {
      groups.add(
          lesson.vocabList.sublist(i, min(i + 4, lesson.vocabList.length)));
    }

    final random = Random();
    List<List<List<VocabStep>>> stepsGrouped = [];

    List<String> allWords = [];
    for (VocabModel v in lesson.vocabList) {
      for (String s in v.learnLang.split(" ")) {
        allWords.add(s);
      }
    }

    VocabStep? genVocabStep(VocabStepType type, VocabModel vocab) {
      switch (type) {
        case VocabStepType.select:
          // TODO: Add Audio to options
          return VocabStep(
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
        case VocabStepType.listen:
          return VocabStep(
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
        case VocabStepType.compose:
          if (vocab.learnLang.split(" ").length == 1) return null;
          final correctOptions = vocab.learnLang.split(" ");
          return VocabStep(
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

        case VocabStepType.pronounce:
          return VocabStep(
            prompt: vocab.learnLang,
            answer: vocab.learnLang,
            type: type,
            audioUrl: vocab.audioUrl,
          );

        case VocabStepType.write:
          return VocabStep(
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
        stepsGrouped[i][0].add(genVocabStep(stage_1[s1I], v)!);
        final s2 = genVocabStep(stage_2[s2I], v);
        if (s2 != null) {
          stepsGrouped[i][1].add(s2);
        }
        final s3 = genVocabStep(stage_2[s3I], v);
        if (s3 != null) {
          stepsGrouped[i][1].add(s3);
        }
      }
      stepsGrouped[i][1].shuffle();
      stepsGrouped[i][2].shuffle();
    }

    List<VocabStep> steps = [];
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
      "currentStep": _currentStep,
    });
  }

  void submitAnswer() {
    // TODO: Add Error logging
    currentStep!.userAnswer = _currentAnswer;
    notifyListeners();
  }

  void nextStep() {
    // TODO: implement Review and finish

    _currentAnswer = null;
    if (_currentStep != _steps.length - 1) {
      _currentStep = _currentStep! + 1;
      notifyListeners();
    }
  }

  void cacheAudio() async {
    final tmpDir = await getTemporaryDirectory();
    for (VocabModel v in lesson.vocabList) {
      final file = File("${tmpDir.path}/${v.audioUrl}");
      file.create(recursive: true);
      FirebaseStorage.instance.ref(v.audioUrl).writeToFile(file);
    }
  }
}

enum VocabStepType {
  write,
  compose,
  pronounce,
  select,
  listen,
}

class VocabStep {
  VocabStepType type;
  final String prompt;
  final String answer;
  final String? audioUrl;
  final List<String>? options;
  String? userAnswer;
  bool? get isCorrect {
    return userAnswer == null
        ? null
        : getNormifiedString(answer) == getNormifiedString(userAnswer!);
  }

  VocabStep(
      {required this.prompt,
      required this.answer,
      required this.type,
      this.userAnswer,
      this.audioUrl,
      this.options}) {
    options?.shuffle();
  }

  factory VocabStep.fromJson(Map<String, dynamic> json) {
    return VocabStep(
      prompt: json['prompt'],
      answer: json['answer'],
      type: VocabStepType.values[json['stepType']],
      audioUrl: json['audioUrl'],
      options: json['options'],
      userAnswer: json['userAnswer'],
    );
  }

  String toJson() {
    return jsonEncode({
      "prompt": prompt,
      "answer": answer,
      "stepType": type.index,
      "audioUrl": audioUrl,
      "options": options,
      "userAnswer": userAnswer,
    });
  }
}

List<int> generateRandomIntegers(int n, int max, {int min = 0}) {
  final random = Random();
  final List<int> list = [];
  while (list.length < n) {
    final r = random.nextInt(max - min) + min;
    if (!list.contains(r)) {
      list.add(r);
    }
  }
  return list;
}

String getNormifiedString(String str) {
  return str
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^\w\s]+'), '')
      .withoutDiacriticalMarks;
}

extension DiacriticsAwareString on String {
  static const diacritics =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž';
  static const nonDiacritics =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz';

  String get withoutDiacriticalMarks => splitMapJoin('',
      onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
          ? nonDiacritics[diacritics.indexOf(char)]
          : char);
}
