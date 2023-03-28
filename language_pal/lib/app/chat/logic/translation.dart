import 'package:cloud_functions/cloud_functions.dart';
import 'package:language_pal/common/languages.dart';

Future<String> getTranslations(String msg, String lang) async {
  // Call cloud function to get translations
  final response = await FirebaseFunctions.instance
      .httpsCallable('getTranslation')
      .call({"text": msg, "lang": convertLangCode(lang).getEnglishName()});
  return response.data;
}
