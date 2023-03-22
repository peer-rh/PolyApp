import 'dart:convert';

import 'package:flutter/services.dart';

class ScenarioModel {
  String name;
  String emoji;
  String avatar;
  String prompt;
  String shortDesc;
  String assistantName;
  List<String> startMessages;
  ScenarioModel(this.name, this.prompt, this.startMessages, this.emoji,
      this.avatar, this.shortDesc, this.assistantName);
}

Future<List<ScenarioModel>> loadScenarioModels(String language) async {
  String scenarioPrompt =
      await rootBundle.loadString('assets/prompts/scenario.txt');
  scenarioPrompt = scenarioPrompt.replaceAll("<LEANRN_LANG>", language);

  final String scenarios =
      await rootBundle.loadString('assets/prompts/scenarios.json');
  List<dynamic> map = await json.decode(scenarios);
  return map.map((e) {
    return ScenarioModel(
        e["name"],
        scenarioPrompt.replaceAll("<SCENARIO>", e["name"]),
        e["starting_msgs"].cast<String>(),
        e["emoji"],
        e["avatar"],
        e["short_desc"],
        e["assistant_name"]);
  }).toList();
}
