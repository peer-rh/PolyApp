import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class UseCaseModel {
  final String uniqueId;
  final String title;
  final String emoji;
  final List<String> recommended;

  UseCaseModel(this.uniqueId, this.title, this.emoji, this.recommended);
}

Future<List<UseCaseModel>> loadUseCaseModels(String ownLang) async {
  List<dynamic> map =
      json.decode(FirebaseRemoteConfig.instance.getString("use_cases"));
  return map.map((e) {
    return UseCaseModel(
      e["id"],
      e["name"][ownLang],
      e["emoji"],
      e["recommended"].cast<String>(),
    );
  }).toList();
}

Future<UseCaseModel?> loadUseCaseModel(String uniqueId, String ownLang) async {
  final List<UseCaseModel> useCases = await loadUseCaseModels(ownLang);
  return useCases.firstWhere((element) => element.uniqueId == uniqueId);
}
