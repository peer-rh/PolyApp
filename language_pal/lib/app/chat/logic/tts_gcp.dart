import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String _apiKey = dotenv.env['GCP_API_KEY']!;

Future<dynamic> generateTextToSpeech(String msg) async {
  // Make post request to Google Cloud Text-to-Speech API
  final data = (await FirebaseFunctions.instance
          .httpsCallable('generateTextToSpeech')
          .call({
    "language_code": "de-DE",
    "gender": "FEMALE",
    "text": msg,
  }))
      .data;
  print(data["audioContent"]);
  return base64Decode(data["audioContent"]);
}
