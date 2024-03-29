class UseCaseModel {
  final String uniqueId;
  final String title;
  final String emoji;
  final List<String> recommended;

  UseCaseModel(this.uniqueId, this.title, this.emoji, this.recommended);

  factory UseCaseModel.fromMap(Map<String, dynamic> map, String appLanguage) {
    return UseCaseModel(
      map['id'],
      map['name'][appLanguage],
      map['emoji'],
      map['recommended'].cast<String>(),
    );
  }
}

// new
enum UseCaseType {
  travel("travel"),
  job("job"),
  studies("studies"),
  interest("interest"),
  move("move");

  const UseCaseType(this.code);
  final String code;

  factory UseCaseType.fromCode(String code) {
    switch (code) {
      case "travel":
        return UseCaseType.travel;
      case "job":
        return UseCaseType.job;
      case "studies":
        return UseCaseType.studies;
      case "interest":
        return UseCaseType.interest;
      case "move":
        return UseCaseType.move;
      default:
        throw Exception("Unknown use case type: $code");
    }
  }
}
