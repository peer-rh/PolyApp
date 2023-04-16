import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

LanguageModel convertLangCode(String code) {
  switch (code) {
    case "de":
      return LanguageModel("de", "🇩🇪");
    case "en":
      return LanguageModel("en", "🇬🇧");
    case "es":
      return LanguageModel("es", "🇪🇸");
    default:
      return LanguageModel("en", "🇬🇧");
  }
}

class LanguageModel {
  String code;
  String emoji;

  LanguageModel(this.code, this.emoji);
  String getName(BuildContext context) =>
      AppLocalizations.of(context)!.language(code);

  String getEnglishName() {
    switch (code) {
      case "en":
        return "english";
      case "de":
        return "german";
      case "es":
        return "spanish";
      default:
        return "english";
    }
  }

  String getSpeechRecognitionLocale() {
    switch (code) {
      case "en":
        return "en_US";
      case "de":
        return "de_DE";
      case "es":
        return "es_ES";
      default:
        return "en_US";
    }
  }
}

List<LanguageModel> supportedAppLanguages() {
  return [
    LanguageModel("en", "🇬🇧"),
    LanguageModel("de", "🇩🇪"),
  ];
}

List<LanguageModel> supportedLearnLanguages() {
  return [
    LanguageModel("en", "🇬🇧"),
    LanguageModel("de", "🇩🇪"),
    LanguageModel("es", "🇪🇸"),
  ];
}
