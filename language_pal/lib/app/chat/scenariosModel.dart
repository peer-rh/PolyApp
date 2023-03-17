import 'dart:convert';

import 'package:flutter/services.dart';

class ScenarioModel {
  String name;
  String iconURL = "";
  List<String> beginningMsgs;
  String prompt;
  ScenarioModel(this.name, this.prompt, this.beginningMsgs);

  factory ScenarioModel.fromJson(Map<String, dynamic> obj) {
    return ScenarioModel(
        obj["name"], obj["prompt"], List<String>.from(obj["beginning_msgs"]));
  }
}

Future<List<ScenarioModel>> loadScenariosFromJson(String path) async {
  final String response = await rootBundle.loadString(path);
  List<dynamic> map = await json.decode(response);
  return map.map((e) => ScenarioModel.fromJson(e)).toList();
}
