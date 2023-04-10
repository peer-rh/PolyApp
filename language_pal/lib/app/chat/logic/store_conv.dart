import 'dart:convert';
import 'dart:io';

import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:path_provider/path_provider.dart';

Future<Conversation?> loadConv(ScenarioModel scenario) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  File convFile =
      File('${appDir.path}/conversations/${scenario.uniqueId}.json');
  if (await convFile.exists()) {
    Map<String, dynamic> convJson = jsonDecode(await convFile.readAsString());
    return Conversation.fromFirestore(convJson, scenario);
  }
  return null;
}

void storeConv(Conversation msgs) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  File convFile =
      File('${appDir.path}/conversations/${msgs.scenario.uniqueId}.json');
  if (!await convFile.exists()) {
    await convFile.create(recursive: true);
  }
  convFile.writeAsString(jsonEncode(msgs.toFirestore()));
}

Future<void> deleteConv(ScenarioModel scenario) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  File convFile =
      File('${appDir.path}/conversations/${scenario.uniqueId}.json');
  if (await convFile.exists()) {
    await convFile.delete();
  }
}
