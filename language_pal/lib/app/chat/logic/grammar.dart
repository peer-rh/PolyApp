import 'package:cloud_functions/cloud_functions.dart';

Future<String?> getGrammarCorrection(String lang, String msg) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable('getGrammarCorrection')
      .call({"text": msg, "lang": lang});
  String data = response.data;
  if (data == "[correct]") {
    return null;
  } else {
    return data;
  }
}
