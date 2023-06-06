import 'package:poly_app/app/lessons/common/util.dart';

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
      this.options}) {
    options?.shuffle();
  }

  factory InputStep.fromJson(Map<String, dynamic> json) {
    return InputStep(
      prompt: json['prompt'],
      answer: json['answer'],
      type: InputType.values[json['stepType']],
      options: json['options']?.cast<String>(),
      userAnswer: json['userAnswer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "prompt": prompt,
      "answer": answer,
      "stepType": type.index,
      "options": options,
      "userAnswer": userAnswer,
    };
  }

  InputStep copy() => InputStep(
      prompt: prompt,
      answer: answer,
      type: type,
      options: options,
      userAnswer: userAnswer);
}
