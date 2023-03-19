import 'package:cloud_functions/cloud_functions.dart';

Future<String> getTranslations(String msg, String lang) async {
  // Call cloud function to get translations
  final response = await FirebaseFunctions.instance
      .httpsCallable('getTranslation')
      .call({"text": msg, "lang": lang});
  return response.data;
}
