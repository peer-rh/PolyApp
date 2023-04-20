import 'dart:convert';
import 'dart:io';

import 'package:language_pal/app/chat/data/conversation.dart';
import 'package:language_pal/app/chat/logic/conversation_provider.dart';
import 'package:path_provider/path_provider.dart';

extension StoreConversation on ConversationProvider {
  Future<File> _getConvFile() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    return File(
        '$appDir/conversations/${learnLang.code}/${scenario.uniqueId}.json');
  }

  Future<void> storeConv() async {
    File convFile = await _getConvFile();
    if (!await convFile.exists()) {
      await convFile.create(recursive: true);
    }
    convFile.writeAsString(
        jsonEncode({"conv": conv.toFirestore(), "status": status.index}));
  }

  Future<bool> loadConv() async {
    File convFile = await _getConvFile();
    if (await convFile.exists()) {
      Map<String, dynamic> convJson = jsonDecode(await convFile.readAsString());
      conv = Conversation.fromFirestore(convJson["conv"]);
      status = ConversationStatus.values[convJson["status"]];
      return true;
    }
    return false;
  }

  Future<void> deleteConv() async {
    File convFile = await _getConvFile();
    if (await convFile.exists()) {
      await convFile.delete();
    }
  }
}

Future<bool> conversationExists(String learnLang, String scenarioId) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  File file = File('$appDir/conversations/$learnLang/$scenarioId.json');
  return file.existsSync();
}
