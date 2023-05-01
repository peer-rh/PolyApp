import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poly_app/app/user/logic/learn_language_provider.dart';
import 'package:poly_app/common/data/scenario_model.dart';

final scenarioMap =
    json.decode(FirebaseRemoteConfig.instance.getString("scenarios"));

final scenarioProvider = Provider<Map<String, ScenarioModel>>((ref) {
  final appLang = Intl.shortLocale(Intl.getCurrentLocale());
  final learnLang = ref.watch(learnLangProvider).code;

  return {
    for (var e in scenarioMap)
      e["id"]: ScenarioModel.fromMap(e, learnLang, appLang)
  };
});
