import 'package:poly_app/app/lessons/logic/util.dart';

enum InputType {
  write,
  compose,
  pronounce,
  select,
  listen,
}

class InputStep {
  InputType type;
  final String prompt;
  final String answer;
  final String? audioUrl;
  final List<String>? options;
  String? userAnswer;
  bool? get isCorrect {
    return userAnswer == null
        ? null
        : getNormifiedString(answer) == getNormifiedString(userAnswer!);
  }

  InputStep(
      {required this.prompt,
      required this.answer,
      required this.type,
      this.userAnswer,
      this.audioUrl,
      this.options}) {
    options?.shuffle();
  }

  factory InputStep.fromJson(Map<String, dynamic> json) {
    print(json);
    return InputStep(
      prompt: json['prompt'],
      answer: json['answer'],
      type: InputType.values[json['stepType']],
      audioUrl: json['audioUrl'],
      options: json['options']?.cast<String>(),
      userAnswer: json['userAnswer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "prompt": prompt,
      "answer": answer,
      "stepType": type.index,
      "audioUrl": audioUrl,
      "options": options,
      "userAnswer": userAnswer,
    };
  }
}
