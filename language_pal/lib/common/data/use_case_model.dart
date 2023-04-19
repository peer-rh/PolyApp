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
