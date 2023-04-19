import 'dart:convert';
import 'dart:io';

import 'package:language_pal/app/chat/models/messages.dart';
import 'package:path_provider/path_provider.dart';

Future<File> getConvFile(ScenarioModel scenario) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  return getConvFileFromStrings(
      appDir.path, scenario.learnLang, scenario.uniqueId);
}

File getConvFileFromStrings(
    String appDir, String learnLang, String scenarioID) {
  return File('$appDir/conversations/$learnLang/$scenarioID.json');
}

Future<Conversation?> loadConv(ScenarioModel scenario) async {
  File convFile = await getConvFile(scenario);
  if (await convFile.exists()) {
    Map<String, dynamic> convJson = jsonDecode(await convFile.readAsString());
    return Conversation.fromFirestore(convJson, scenario);
  }
  return null;
}

void storeConv(Conversation msgs) async {
  File convFile = await getConvFile(msgs.scenario);
  if (!await convFile.exists()) {
    await convFile.create(recursive: true);
  }
  convFile.writeAsString(jsonEncode(msgs.toFirestore()));
}

Future<void> deleteConv(ScenarioModel scenario) async {
  File convFile = await getConvFile(scenario);
  if (await convFile.exists()) {
    await convFile.delete();
  }
}
