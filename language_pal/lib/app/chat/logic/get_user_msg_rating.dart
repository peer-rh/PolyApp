import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:poly_app/app/chat/data/messages.dart';
import 'package:poly_app/app/chat/data/user_msg_rating_model.dart';
import 'package:poly_app/app/chat/logic/conversation_provider.dart';
import 'package:poly_app/app/chat/logic/get_ai_response.dart';

extension UserMsgRatingExt on ConversationProvider {
  void getUserMsgRating(SingularPersonMsgModel msg) async {
    status = ConversationStatus.waitingForUserMsgRating;
    var data = await _getFirebaseResponse(msg);
    MsgRatingType type = MsgRatingType.fromString(data["type"]);

    if (type == MsgRatingType.notParse) {
      FirebaseCrashlytics.instance.recordError(
          Exception("Invalid result type: ${data.toString()}"),
          StackTrace.current);
    }

    data["type"] = type.index;
    msg.rating = UserMsgRating.fromFirestore(data);
    if (msg.rating!.type == MsgRatingType.correct) {
      getAIResponse();
    } else {
      status = ConversationStatus.waitingForUserRedo;
    }
  }

  Future<Map<String, dynamic>> _getFirebaseResponse(
      SingularPersonMsgModel msg) async {
    final response =
        await FirebaseFunctions.instance.httpsCallable('getAnswerRating').call({
      "environment": scenario.environmentDesc,
      "assistant_name": scenario.ratingAssistantName,
      "messages": conv.getLastMsgs(4), // Remove Scenario Msg
      "language": appLang.englishName,
    });

    return response.data;
  }
}
