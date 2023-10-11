import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';

final learnLangProvider = Provider<LanguageModel>((ref) {
  final id = ref.watch(currentLearnTrackIdProvider);
  if (id == null) {
    return LanguageModel.fromCode("en");
  }
  return id.learnLang;
});

final appLangProvider = Provider<LanguageModel>((ref) {
  final id = ref.watch(currentLearnTrackIdProvider);
  if (id == null) {
    return LanguageModel.fromCode("en");
  }
  return id.appLang;
});

final staticFirestoreDoc = Provider<DocumentReference>((ref) {
  final id = ref.watch(currentLearnTrackIdProvider);
  return FirebaseFirestore.instance
      .collection("static")
      .doc(id == null ? "en_es" : "${id.appLang.code}_${id.learnLang.code}");
});

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

  String get hello {
    switch (code) {
      case "en":
        return "Hello";
      case "de":
        return "Hallo";
      case "es":
        return "Hola";
      default:
        return "Hello";
    }
  }

  Map<String, dynamic> get defaultVoice {
    return switch (code) {
      "de" => {
          "name": "de-DE-Neural2-B",
          "language_code": "de-DE",
          "pitch": -4
        },
      "en" => {
          "name": "en-US-Neural2-A",
          "language_code": "en-US",
          "pitch": -4
        },
      "es" => {
          "name": "es-ES-Neural2-B",
          "language_code": "es-ES",
          "pitch": -4
        },
      _ => throw Exception("Language not supported")
    };
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
