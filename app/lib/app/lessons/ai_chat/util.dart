import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/common/logic/languages.dart';

final translationProvider = Provider<TranslationProvider>((ref) {
  final appLang = ref.watch(appLangProvider);
  return TranslationProvider(appLang.englishName);
});

class TranslationProvider {
  String appLang;
  final Map<String, String> _cache = {};

  TranslationProvider(this.appLang);

  Future<String> translate(String msg) async {
    if (_cache.containsKey(msg)) {
      return _cache[msg]!;
    }
    final translation = await FirebaseFunctions.instance
        .httpsCallable("translate")({"text": msg, "target": appLang});
    _cache[msg] = translation.data;
    return translation.data;
  }
}
