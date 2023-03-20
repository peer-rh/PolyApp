import 'package:cloud_functions/cloud_functions.dart';

Future<String?> getGrammarCorrection(String msg) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable('getGrammarCorrection')
      .call({"text": msg});
  String data = response.data;
  if (data == "Yes" || data == "yes" || data == "Yes." || data == "yes.") {
    return null;
  } else {
    return data;
  }
}
