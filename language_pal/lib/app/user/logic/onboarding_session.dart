import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/common/data/use_case_model.dart';
import 'package:poly_app/common/logic/languages.dart';

final activeOnboardingSession =
    ChangeNotifierProvider.autoDispose<OnboardingSession>(
        (ref) => OnboardingSession());

class OnboardingSession extends ChangeNotifier {
  final List<OnboardingMsgModel> _msgs = [];
  List<OnboardingMsgModel> get msgs => _msgs;
  final ValueNotifier<OnboardingState> _state =
      ValueNotifier(OnboardingState.waitingForUser);
  get state => _state.value;

  ({LanguageModel lang, UseCaseType useCase})? _result;
  ({LanguageModel lang, UseCaseType useCase})? get result => _result;

  OnboardingSession() {
    _msgs.add(OnboardingMsgModel(true,
        "Hello I'm Poly, your language learning assistant. Great to hear, that you are interested in learning a new language. What Language would you like to learn?"));
    _state.addListener(() {
      notifyListeners();
    });
  }

  void addUserMsg(String msg) {
    _msgs.add(OnboardingMsgModel(false, msg));
    _getAIResponse();
    _state.value = OnboardingState.waitingForAI;
    notifyListeners();
  }

  void _getAIResponse() async {
    final response = await FirebaseFunctions.instance
        .httpsCallable("onboardingGetChatGPTResponse")
        .call({
      "messages": _msgs.map((e) => e.toGpt()).toList(),
    });

    Map<String, dynamic> res = response.data;
    if (res["language"] != null) {
      _result = (
        lang: LanguageModel.fromCode(res["language"]!),
        useCase: UseCaseType.fromCode(res["reason"]!)
      );
      _msgs.add(OnboardingMsgModel(true, res["message"]!));
      _state.value = OnboardingState.finished;
    } else {
      _msgs.add(OnboardingMsgModel(true, res["message"]!));
      _state.value = OnboardingState.waitingForUser;
    }
  }
}

class OnboardingMsgModel {
  final bool isAi;
  final String msg;

  OnboardingMsgModel(this.isAi, this.msg);

  Map<String, dynamic> toGpt() {
    return {"content": msg, "role": isAi ? "assistant" : "user"};
  }
}

enum OnboardingState { waitingForUser, waitingForAI, finished }
