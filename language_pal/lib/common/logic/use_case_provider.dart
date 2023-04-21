import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:language_pal/common/data/use_case_model.dart';

final List<dynamic> useCaseMap =
    json.decode(FirebaseRemoteConfig.instance.getString('use_cases'));

final useCaseProvider = Provider<Map<String, UseCaseModel>>((ref) {
  final appLanguage = Intl.shortLocale(Intl.getCurrentLocale());
  return {
    for (var e in useCaseMap) e["id"]: UseCaseModel.fromMap(e, appLanguage)
  };
});
