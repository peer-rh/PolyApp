import 'dart:convert';

import 'package:flutter/services.dart';

class ScenarioModel {
  String name;
  String emoji;
  String avatar;
  String prompt;
  List<String> startMessages;
  ScenarioModel(
      this.name, this.prompt, this.startMessages, this.emoji, this.avatar);
}

Future<List<ScenarioModel>> loadScenarioModels(String language) async {
  String scenario_prompt =
      await rootBundle.loadString('assets/prompts/scenario.txt');
  scenario_prompt = scenario_prompt.replaceAll("<LEANRN_LANG>", language);

  final String scenarios =
      await rootBundle.loadString('assets/prompts/scenarios.json');
  List<dynamic> map = await json.decode(scenarios);
  return map.map((e) {
    return ScenarioModel(
      e["name"],
      scenario_prompt.replaceAll("<SCENARIO>", e["name"]),
      e["starting_msgs"].cast<String>(),
      e["emoji"],
      e["avatar"],
    );
  }).toList();
}
