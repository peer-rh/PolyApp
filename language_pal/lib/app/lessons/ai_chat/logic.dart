import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/lesson_model.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/app/learn_track/logic/lesson_provider.dart';
import 'package:poly_app/app/lessons/ai_chat/data.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/common/logic/languages.dart';

final activeChatId = StateProvider<String?>((ref) => null);

final activeChatSession = ChangeNotifierProvider<ActiveChatSession?>((ref) {
  final id = ref.watch(activeChatId);
  if (id == null) {
    return null;
  }
  final mockChatLesson = ref.watch(aiChatLessonProvider(id));
  final lesson = mockChatLesson.asData?.value;
  final trackId = ref.watch(currentLearnTrackIdProvider);
  final uid = ref.watch(uidProvider);
  if (lesson == null || trackId == null || uid == null) {
    return null;
  }
  final out = ActiveChatSession(
      lesson, uid, ref.watch(learnLangProvider), ref.watch(appLangProvider));
  return out;
});

class ActiveChatSession extends ChangeNotifier {
  final AiChatLessonModel lesson;
  final String _uid;
  final LanguageModel learnLang;
  final LanguageModel appLang;

  final ValueNotifier<ChatStatus> _status =
      ValueNotifier(ChatStatus.initialising);
  get status => _status.value;

  // TODO: Maybe make late and not optional
  List<ChatMsg>? _msgs;
  List<ChatMsg>? get msgs => _msgs;

  String? _finalRating;
  String? get finalRating => _finalRating;

  ({String learnLang, String appLang})? get currentSuggestion {
    if (_msgs?.last is UserChatMsg) {
      final rating = (_msgs!.last as UserChatMsg).rating;
      if (rating == null) {
        return null;
      }
      return (
        learnLang: rating.suggestion!,
        appLang: rating.suggestionTranslated!
      );
    }
    return null;
  }

  bool get finished => _finalRating != null;

  ActiveChatSession(this.lesson, this._uid, this.learnLang, this.appLang) {
    _status.addListener(() {
      notifyListeners();
      switch (_status.value) {
        case ChatStatus.waitingForAIResponse:
          _getAiResponse();
          break;
        case ChatStatus.waitingForUserMsgRating:
          _getRating();
          break;
        case ChatStatus.waitingForConvRating:
          _getFinalRating();
          break;
        default:
          break;
      }
    });
    _initState();
  }

  void _initState() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("lessons")
        .doc(lesson.id)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      _msgs = (data["msgs"] as List<dynamic>)
          .map((e) => ChatMsg.fromJson(e))
          .toList();
      _finalRating = data["finalRating"] as String?;
      _status.value = ChatStatus.fromString(data["status"]);
    } else {
      _msgs = [AIChatMsg(lesson.startingMsg)];
      _finalRating = null;
      _status.value = ChatStatus.waitingForUser;
    }
  }

  void saveState() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("lessons")
        .doc(lesson.id)
        .set({
      "msgs": _msgs!.map((e) => e.toJson()).toList(),
      "finalRating": _finalRating,
      "status": _status.value.name
    });
  }

  List<Map<String, String>> getLastMessages(int n) {
    List<Map<String, String>> out = [];
    bool? isAi;
    for (var element in _msgs!.reversed) {
      if (out.length >= n) {
        continue;
      }
      isAi ??= !element.isAi;
      if (element.isAi != isAi) {
        out.add(element.toGpt());
        isAi = !isAi;
      }
    }
    return out;
  }

  void addMsg(UserChatMsg msg, {skipRating = false}) async {
    _msgs!.add(msg);
    notifyListeners();

    if (!skipRating) {
      _status.value = ChatStatus.waitingForUserMsgRating;
    }
  }

  void _getRating() async {
    final response =
        await FirebaseFunctions.instance.httpsCallable('getAnswerRating').call({
      "prompt_desc": lesson.promptDesc,
      "messages": getLastMessages(4), // Remove Scenario Msg
      "app_lang": appLang.englishName,
      "learn_lang": learnLang.englishName,
    });

    var data = response.data as Map<String, dynamic>;
    MsgRatingType type = MsgRatingType.fromString(data["type"]);

    if (type == MsgRatingType.notParse) {
      FirebaseCrashlytics.instance.recordError(
          Exception("Invalid result type: ${data.toString()}"),
          StackTrace.current);
    }

    data["type"] = type.index;

    (_msgs!.last as UserChatMsg).rating = UserMsgRating.fromJson(data);
    if (type == MsgRatingType.correct) {
      _status.value = ChatStatus.waitingForAIResponse;
    } else {
      _status.value = ChatStatus.waitingForUserRedo;
    }
  }

  void _getAiResponse() async {
    final response = await FirebaseFunctions.instance
        .httpsCallable("getChatGPTResponse")
        .call({
      "learn_lang": learnLang.englishName,
      "messages": getLastMessages(8),
      "prompt_desc": lesson.promptDesc
    });

    String msg = response.data;
    if (msg.toLowerCase().contains("[end]")) {
      msg = msg.substring(0, msg.toLowerCase().indexOf("[end]")).trim();
      _msgs!.add(AIChatMsg(msg));
      _status.value = ChatStatus.waitingForConvRating;
    } else {
      _msgs!.add(AIChatMsg(msg));
      _status.value = ChatStatus.waitingForUser;
    }
  }

  void _getFinalRating() async {
    final response = await FirebaseFunctions.instance
        .httpsCallable("getConversationRating")
        .call({
      "learn_lang": learnLang.englishName,
      "app_lang": appLang.englishName,
      "messages": getLastMessages(msgs!.length),
      "prompt_desc": lesson.promptDesc,
    });

    _finalRating = response.data;
    _status.value = ChatStatus.finished;
  }
}
