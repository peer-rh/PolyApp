import 'package:cloud_functions/cloud_functions.dart';
import 'package:poly_app/app/chat/data/conversation.dart';
import 'package:poly_app/common/data/use_case_model.dart';
import 'package:poly_app/common/logic/languages.dart';

class OnboardingResponse {
  String message;
  LanguageModel? language;
  UseCaseType? useCase;
  OnboardingResponse(this.message, {this.language, this.useCase});
}

Future<OnboardingResponse> getAIOnboardingResponse(Conversation conv) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable("onboardingGetChatGPTResponse")
      .call({
    "messages": conv.getLastMsgs(8),
  });

  Map<String, dynamic> res = response.data;
  if (res["language"] != null) {
    return OnboardingResponse(res["message"]!,
        language: LanguageModel.fromCode(res["language"]!),
        useCase: UseCaseType.fromCode(res["reason"]!));
  }
  return OnboardingResponse(res["message"]!);
}
