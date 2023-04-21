import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:language_pal/app/chat/data/conversation.dart';
import 'package:language_pal/app/chat/data/messages.dart';
import 'package:language_pal/app/chat/logic/get_ai_response.dart';
import 'package:language_pal/app/chat/logic/get_user_msg_rating.dart';
import 'package:language_pal/app/chat/logic/store_conv.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:language_pal/common/data/scenario_model.dart';
import 'package:language_pal/common/logic/languages.dart';

final conversationProvider =
    ChangeNotifierProvider.family<ConversationProvider, ScenarioModel>(
        (ref, scenario) {
  final user = ref.watch(userProvider).user!;
  final conv = ConversationProvider(scenario, user.learnLang, user.uid);
  ref.onDispose(() {
    conv.dispose();
  });
  return conv;
});

enum ConversationStatus {
  initialising,
  waitingForUser,
  waitingForUserRedo,
  waitingForUserMsgRating,
  waitingForAIResponse,
  waitingForConvRating,
  finished,
}

class ConversationProvider extends ChangeNotifier {
  late Conversation conv;
  late ScenarioModel scenario;
  final ValueNotifier<ConversationStatus> _status =
      ValueNotifier(ConversationStatus.initialising);
  late LanguageModel learnLang;
  late LanguageModel appLang;
  String uid;
  PersonMsgListModel? currentUserMsg;

  ConversationStatus get status => _status.value;
  set status(ConversationStatus value) {
    _status.value = value;
  }

  bool get isEmpty => conv.msgs.length == 1;

  ConversationProvider(this.scenario, String learnLang, this.uid) {
    Conversation(scenario.uniqueId, learnLang);
    this.learnLang = LanguageModel.fromCode(learnLang);
    _status.addListener(() {
      notifyListeners();
    });
    appLang = LanguageModel.fromCode(Intl.shortLocale(Intl.getCurrentLocale()));
    conv = Conversation(scenario.uniqueId, learnLang);
    initChat();
  }

  @override
  void dispose() {
    if (!isEmpty && status != ConversationStatus.finished) {
      storeConv();
    }
    super.dispose();
  }

  void initChat({checkFile = true}) async {
    bool exists = false;
    if (checkFile) {
      exists = await loadConv();
    }
    if (!exists) {
      addAIMsg(scenario
          .startMessages[Random().nextInt(scenario.startMessages.length)]);
      status = ConversationStatus.waitingForUser;
    }
  }

  void reset() {
    conv = Conversation(scenario.uniqueId, learnLang.code);
    status = ConversationStatus.initialising;
    deleteConv();
    initChat(checkFile: false);
    currentUserMsg = null;
  }

  void addAIMsg(String msg) {
    conv.addMsg(AIMsgModel(msg));
  }

  void addPersonMsg(String msg, {bool suggested = false}) {
    final thisMsg = SingularPersonMsgModel(msg, suggested: suggested);
    if (currentUserMsg == null) {
      currentUserMsg = PersonMsgListModel([thisMsg]);
      conv.addMsg(currentUserMsg!);
    } else {
      currentUserMsg!.msgs
          .add(thisMsg); // TODO: Check if this also updates the conv
    }
    if (suggested) {
      getAIResponse();
    } else {
      getUserMsgRating(thisMsg);
    }
  }
}
