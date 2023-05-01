import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

final learnLangListProvider = Provider<List<LanguageModel>>((ref) {
  final codes = ref.watch(userProvider).user?.learnTrackList;
  if (codes == null) return [];
  return codes.map((code) => LanguageModel.fromCode(code)).toList();
});

final learnLangProvider =
    StateNotifierProvider<LearnLanguageProvider, LanguageModel>((ref) {
  final learnLangs = ref.watch(learnLangListProvider);
  if (learnLangs.isEmpty) {
    return LearnLanguageProvider([LanguageModel.fromCode("en")]);
  }
  return LearnLanguageProvider(learnLangs);
});

class LearnLanguageProvider extends StateNotifier<LanguageModel> {
  List<LanguageModel> learnLangList;

  LearnLanguageProvider(this.learnLangList) : super(learnLangList.first) {
    // Get last stored state with shared preferences
    if (learnLangList.isNotEmpty) _loadSharedPrefLanguage();
  }

  void _loadSharedPrefLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLearnLangCode = prefs.getString('learnLangCode');
    if (lastLearnLangCode != null) {
      final lastLearnLang = learnLangList.firstWhere(
          (lang) => lang.code == lastLearnLangCode,
          orElse: () => learnLangList.first);
      state = lastLearnLang;
    }
  }

  void _saveSharedPrefLanguage(LanguageModel lang) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('learnLangCode', lang.code);
  }

  void setLearnLanguage(LanguageModel lang) {
    if (!learnLangList.contains(lang)) {
      FirebaseCrashlytics.instance.recordError(
        Exception('Learn language $lang not in list'),
        StackTrace.current,
      );
      return;
    }
    state = lang;
    _saveSharedPrefLanguage(lang);
  }
}
