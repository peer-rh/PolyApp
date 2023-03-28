import 'dart:convert';

import 'package:flutter/services.dart';

class UseCaseModel {
  final String uniqueId;
  final String title;
  final String emoji;
  final List<String> recommended;

  UseCaseModel(this.uniqueId, this.title, this.emoji, this.recommended);
}

Future<List<UseCaseModel>> loadUseCaseModels(String ownLang) async {
  final String useCases = await rootBundle.loadString('assets/use_cases.json');
  List<dynamic> map = await json.decode(useCases);
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
