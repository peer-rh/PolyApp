import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

// TODO: Cache this in the MsgModel
Future<dynamic> generateTextToSpeech(String msg) async {
  // Make post request to Google Cloud Text-to-Speech API
  final data = (await FirebaseFunctions.instance
      .httpsCallable('generateTextToSpeech')
      .call({
    "language_code": "de-DE",
    "gender": "FEMALE",
    "text": msg,
  }));
  return base64Decode(data.data);
}
