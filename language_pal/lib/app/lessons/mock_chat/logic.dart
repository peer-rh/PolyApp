import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/common/util.dart';
import 'package:poly_app/app/lessons/mock_chat/data.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/abilities.dart';

final staticMockChatProvider =
    FutureProvider.family<StaticMockChatLessonModel, String>((ref, id) async {
  final doc =
      await FirebaseFirestore.instance.collection("lessons").doc(id).get();
  return StaticMockChatLessonModel.fromJson(doc.data()!, id);
});

final activeMockChatId = StateProvider<String?>((ref) => null);

final activeMockChatSession =
    ChangeNotifierProvider<ActiveMockChatSession?>((ref) {
  final id = ref.watch(activeMockChatId);
  if (id == null) {
    return null;
  }
  final mockChatLesson = ref.watch(staticMockChatProvider(id));
  final lesson = mockChatLesson.asData?.value;
  final trackId = ref.watch(currentLearnTrackIdProvider);
  final uid = ref.watch(uidProvider);
  if (lesson == null || trackId == null || uid == null) {
    return null;
  }
  final out = ActiveMockChatSession(lesson, uid);
  ref.listen(cantTalkProvider, (_, newVal) => out.cantTalk = newVal);
  return out;
});

class ActiveMockChatSession extends ChangeNotifier {
  final StaticMockChatLessonModel lesson;
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

  List<MockChatMsg> _steps = [];
  int? _currentStep;

  bool get finished => _currentStep == _steps.length;

  int get currentStepIndex => _currentStep ?? 0;
  InputStep? get currentStep {
    if (_currentStep == null || _currentStep! >= _steps.length) {
      return null;
    }

    final step = _steps[_currentStep!].step!;

    if (step.type == InputType.pronounce && _cantTalk) {
      step.type = InputType.select;
    }
    return step;
  }

  List<MockChatMsg> get pastConv => _steps.sublist(0, _currentStep);

  ActiveMockChatSession(this.lesson, this._uid) {
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
          .map<MockChatMsg>((e) => MockChatMsg.fromJson(e))
          .toList(growable: false);
      _currentStep = await json['currentStep'];
      notifyListeners();
    } else {
      _genProgram();
      notifyListeners();
    }
  }

  void _genProgram() {
    final random = Random();

    List<String> allWords = [];
    for (StaticMockChatMsgModel v in lesson.msgList) {
      for (String s in v.learnLang.split(" ")) {
        allWords.add(s);
      }
    }

    InputStep genInputStep(InputType type, StaticMockChatMsgModel msg) {
      switch (type) {
        case InputType.select:
          return InputStep(
              prompt: msg.appLang,
              answer: msg.learnLang,
              type: type,
              options: [
                msg.learnLang,
                ...generateRandomIntegers(4, lesson.msgList.length)
                    .map((e) => lesson.msgList[e].learnLang)
                    .where((e) => e != msg.learnLang)
                    .take(3)
                    .toList()
              ]);
        case InputType.compose:
          if (msg.learnLang.split(" ").length == 1) {
            return genInputStep(InputType.select, msg);
          }
          final correctOptions = msg.learnLang.split(" ");
          return InputStep(
              prompt: msg.appLang,
              answer: msg.learnLang,
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
              prompt: msg.learnLang,
              answer: msg.learnLang,
              type: type,
              audioUrl: msg.audioUrl,
              options: [
                msg.learnLang,
                ...generateRandomIntegers(4, lesson.msgList.length)
                    .map((e) => lesson.msgList[e].learnLang)
                    .where((e) => e != msg.learnLang)
                    .take(3)
                    .toList()
              ]);

        default:
          throw Exception("Invalid input type");
      }
    }

    for (StaticMockChatMsgModel m in lesson.msgList) {
      _steps.add(MockChatMsg(m.learnLang, m.appLang, m.isAi, m.audioUrl,
          step: m.isAi
              ? null
              : switch (random.nextInt(2)) {
                  0 => genInputStep(InputType.select, m),
                  1 => genInputStep(InputType.compose, m),
                  2 => genInputStep(InputType.pronounce, m),
                  _ => throw Exception("Invalid input type"),
                }));
    }
    _currentStep = _steps[0].isAi ? 1 : 0;
  }

  void saveState() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("lessons")
        .doc(lesson.id)
        .set({
      "steps": _steps.map((e) => e.toJson()).toList(),
      "currentStep": _currentStep!,
    });
  }

  void submitAnswer() {
    // TODO: Add Error logging
    currentStep!.userAnswer = _currentAnswer;
    _currentAnswer = null;
    _currentStep = _currentStep! + 2;
    saveState();
    notifyListeners();
  }
}
