import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:language_pal/common/lang_convert.dart';

const int scoreCompletedCutoff = 80;

class ScenarioModel {
  String uniqueId;
  String name;
  String emoji;
  String avatar;
  String prompt;
  String ratingDesc;
  String ratingName;
  List<String> startMessages;
  Map<String, dynamic> voiceSettings;
  int? userScore;
  bool useCaseRecommended;
  ScenarioModel(
      this.uniqueId,
      this.name,
      this.prompt,
      this.startMessages,
      this.emoji,
      this.avatar,
      this.ratingDesc,
      this.ratingName,
      this.voiceSettings,
      this.useCaseRecommended);
}

Future<List<ScenarioModel>> loadScenarioModels(String learnLang, String ownLang,
    Map<String, int> userScores, List<String> useCaseRecommended) async {
  String scenarioPrompt =
      await rootBundle.loadString('assets/prompts/scenario.txt');
  scenarioPrompt =
      scenarioPrompt.replaceAll("<LEANRN_LANG>", convertLangCode(learnLang));

  final String scenariosFile =
      await rootBundle.loadString('assets/prompts/scenarios.json');
  List<dynamic> map = await json.decode(scenariosFile);
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
