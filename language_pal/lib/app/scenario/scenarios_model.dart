import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:language_pal/common/languages.dart';

const int scoreCompletedCutoff = 8;

class ScenarioModel {
  String uniqueId;
  String name;
  String emoji;
  String avatar;
  String prompt;
  String environmentDesc;
  String ratingAssistantName;
  List<String> startMessages;
  Map<String, dynamic> voiceSettings;
  String goal;
  int? userScore;
  bool useCaseRecommended;
  ScenarioModel(
      this.uniqueId,
      this.name,
      this.prompt,
      this.startMessages,
      this.emoji,
      this.avatar,
      this.environmentDesc,
      this.ratingAssistantName,
      this.voiceSettings,
      this.goal,
      this.useCaseRecommended);
}

Future<List<ScenarioModel>> loadScenarioModels(String learnLang, String ownLang,
    Map<String, int> userScores, List<String> useCaseRecommended) async {
  String scenarioPrompt =
      await rootBundle.loadString('assets/prompts/scenario.txt');
  scenarioPrompt = scenarioPrompt.replaceAll(
      "<LEANRN_LANG>", convertLangCode(learnLang).getEnglishName());

  // final String scenariosFile =
  // await rootBundle.loadString('assets/prompts/scenarios.json');
  // List<dynamic> map = await json.decode(scenariosFile);
  List<dynamic> map =
      json.decode(FirebaseRemoteConfig.instance.getString("scenarios"));
  List<ScenarioModel> scenarios = map.map((e) {
    return ScenarioModel(
        e["id"],
        e["name"][ownLang],
        scenarioPrompt.replaceAll("<SCENARIO>", e["prompt_desc"]),
        (e["starting_msgs"][learnLang] != null)
            ? e["starting_msgs"][learnLang].cast<String>()
            : [],
        e["emoji"],
        e["avatar"],
        e["rating_desc"],
        e["rating_name"],
        e["voice_info"][learnLang],
        e["goal"],
        useCaseRecommended.contains(e["id"]))
      ..userScore = userScores[e["id"]];
  }).toList();

  scenarios.sort((a, b) {
    if ((a.userScore == null || a.userScore! <= scoreCompletedCutoff) &&
        (b.userScore == null || b.userScore! <= scoreCompletedCutoff)) {
      return a.useCaseRecommended ? -1 : 1;
    } else if (a.userScore == null || a.userScore! <= scoreCompletedCutoff) {
      return -1;
    } else if (b.userScore == null || b.userScore! <= scoreCompletedCutoff) {
      return 1;
    } else {
      return a.useCaseRecommended ? -1 : 1;
    }
  });
  return scenarios;
}
