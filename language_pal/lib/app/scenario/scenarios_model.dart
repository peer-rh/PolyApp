import 'dart:convert';

import 'package:flutter/services.dart';

class ScenarioModel {
  String name;
  String emoji;
  String avatar;
  String prompt;
  String ratingDesc;
  String ratingName;
  List<String> startMessages;
  Map<String, dynamic> voiceSettings;
  ScenarioModel(this.name, this.prompt, this.startMessages, this.emoji,
      this.avatar, this.ratingDesc, this.ratingName, this.voiceSettings);
}

Future<List<ScenarioModel>> loadScenarioModels(
    String learnLang, String ownLang) async {
  String scenarioPrompt =
      await rootBundle.loadString('assets/prompts/scenario.txt');
  scenarioPrompt = scenarioPrompt.replaceAll("<LEANRN_LANG>", learnLang);

  final String scenarios =
      await rootBundle.loadString('assets/prompts/scenarios.json');
  List<dynamic> map = await json.decode(scenarios);
  return map.map((e) {
    return ScenarioModel(
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
    );
  }).toList();
}
