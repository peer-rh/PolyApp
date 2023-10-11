class ScenarioModel {
  String uniqueId;
  String name;
  String emoji;
  String avatar;
  String scenarioDesc;
  String environmentDesc;
  String ratingAssistantName;
  List<String> startMessages;
  Map<String, dynamic> voiceSettings;
  String goal;

  ScenarioModel({
    required this.uniqueId,
    required this.name,
    required this.scenarioDesc,
    required this.startMessages,
    required this.emoji,
    required this.avatar,
    required this.environmentDesc,
    required this.ratingAssistantName,
    required this.voiceSettings,
    required this.goal,
  });

  factory ScenarioModel.fromMap(
      Map<String, dynamic> map, String learnLang, String ownLang) {
    return ScenarioModel(
      uniqueId: map["id"],
      name: map["name"][ownLang],
      scenarioDesc: map["prompt_desc"],
      startMessages: map["starting_msgs"][learnLang].cast<String>(),
      emoji: map["emoji"],
      avatar: map["avatar"],
      environmentDesc: map["rating_desc"],
      ratingAssistantName: map["rating_name"],
      voiceSettings: map["voice_info"][learnLang],
      goal: map["goal"],
    );
  }
}
