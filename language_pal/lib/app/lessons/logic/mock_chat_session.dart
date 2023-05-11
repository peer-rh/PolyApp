import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/lessons/data/mock_chat_lesson_model.dart';
import 'package:poly_app/app/lessons/logic/lesson_providers.dart';
import 'package:poly_app/app/lessons/logic/util.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/abilities.dart';

final activeMockChatProvider =
    ChangeNotifierProvider.family<ActiveMockChatSession?, String>((ref, id) {
  final vocabLesson = ref.watch(mockChatLessonProvider(id));
  final lesson = vocabLesson.value;
  final trackId = ref.watch(currentLearnTrackIdProvider);
  final uid = ref.watch(uidProvider);
  if (lesson == null || trackId == null || uid == null) {
    return null;
  }
  final out = ActiveMockChatSession(trackId, lesson, uid);
  ref.listen(cantTalkProvider, (_, newVal) => out.cantTalk = newVal);
  return out;
});

class ActiveMockChatSession extends ChangeNotifier {
  final String _trackId;
  final MockChatLessonModel lesson;
  final String _uid;

  String? _currentAnswer;
  String get currentAnswer => _currentAnswer ?? "";

  bool _cantTalk = false;
  set cantTalk(bool newVal) {
    _cantTalk = newVal;
    notifyListeners();
  }

  set currentAnswer(String? answer) {
    _currentAnswer = answer;
    notifyListeners();
  }

  int? _currentStep;

  int get currentStepIndex => _currentStep ?? 0;

  List<MockChatStep> _steps = [];

  MockChatStep? get currentStep {
    if (_currentStep == null) {
      return null;
    }
    if (_steps[_currentStep!].isAi) _currentStep = _currentStep! + 1;
    if (_steps[_currentStep!].type == MockChatType.pronounce && _cantTalk) {
      _steps[_currentStep!].type = MockChatType.select;
    }
    return _steps[_currentStep!];
  }

  ActiveMockChatSession(this._trackId, this.lesson, this._uid) {
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
      _currentStep = json['currentStep'];
      _steps = json['steps']
          .map<MockChatStep>((e) => MockChatStep.fromJson(e))
          .toList(growable: false);
    } else {
      _genProgram();
    }
    notifyListeners();
  }

  void _genProgram() {
    _currentStep = 0;
    final steps = <MockChatStep>[];
    for (int i = 0; i < lesson.msgList.length; i++) {
      final msg = lesson.msgList[i];
      if (msg.isAi) {
        steps.add(MockChatStep(
          isAi: true,
          appLang: msg.appLang,
          learnLang: msg.learnLang,
          audioUrl: msg.audioUrl,
        ));
      } else {
        steps.add(MockChatStep(
          isAi: false,
          appLang: msg.appLang,
          learnLang: msg.learnLang,
          audioUrl: msg.audioUrl,
          type: MockChatType.select, // TODO: Add Pronounce
        ));
      }
    }
  }

  void saveState() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("lessons")
        .doc(lesson.id)
        .set({
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
    _currentStep = _currentStep! + 1;
    notifyListeners();
  }

  void cacheAudio() async {
    final tmpDir = await getTemporaryDirectory();
    for (MockChatMsgModel v in lesson.msgList) {
      final file = File("${tmpDir.path}/${v.audioUrl}");
      file.create(recursive: true);
      FirebaseStorage.instance.ref(v.audioUrl).writeToFile(file);
    }
  }
}

enum MockChatType {
  pronounce,
  select,
}

class MockChatStep {
  final bool isAi;
  final String appLang;
  final String learnLang;
  final String audioUrl;
  MockChatType? type;
  String? userAnswer;

  bool? get isCorrect {
    return userAnswer == null
        ? null
        : getNormifiedString(learnLang) == getNormifiedString(userAnswer!);
  }

  MockChatStep({
    required this.isAi,
    required this.appLang,
    required this.learnLang,
    required this.audioUrl,
    this.type,
    this.userAnswer,
  });
  factory MockChatStep.fromJson(Map<String, dynamic> json) {
    return MockChatStep(
      isAi: json['isAi'],
      appLang: json['applang'],
      learnLang: json['learnlang'],
      type: MockChatType.values[json['type']],
      audioUrl: json['audioUrl'],
      userAnswer: json['userAnswer'],
    );
  }

  String toJson() {
    return jsonEncode({
      "isAi": isAi,
      "applang": appLang,
      "learnlang": learnLang,
      "type": type!.index,
      "audioUrl": audioUrl,
      "userAnswer": userAnswer,
    });
  }
}
