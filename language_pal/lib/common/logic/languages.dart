import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageModel {
  String code;
  String flag;

  LanguageModel(this.code, this.flag);
  factory LanguageModel.fromCode(String code) {
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

  String getName(BuildContext context) =>
      AppLocalizations.of(context)!.language(code);

  String get englishName {
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

  String get speechRecognitionLocale {
    // TODO: Check if it also works with Android
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

  @override
  bool operator ==(Object other) {
    if (other is LanguageModel) {
      return code == other.code;
    }
    return false;
  }

  @override
  int get hashCode => code.hashCode;
}

List<LanguageModel> supportedAppLanguages() {
  return AppLocalizations.supportedLocales.map((e) {
    return LanguageModel.fromCode(e.languageCode);
  }).toList();
}

List<LanguageModel> supportedLearnLanguages() {
  return ["en", "de", "es"].map((e) {
    return LanguageModel.fromCode(e);
  }).toList();
}
