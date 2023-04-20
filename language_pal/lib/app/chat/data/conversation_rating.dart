class ConversationRating {
  final int? goalScore;
  final int? aiScore;
  final int totalMessages;
  final int totalRetries;
  final int totalScore;
  final String suggestion1;
  final String suggestion2;
  final String suggestion3;

  ConversationRating({
    required this.goalScore,
    required this.aiScore,
    required this.totalMessages,
    required this.totalRetries,
    required this.totalScore,
    required this.suggestion1,
    required this.suggestion2,
    required this.suggestion3,
  });

  Map<String, dynamic> toMap() {
    return {
      "goal_score": goalScore,
      "ai_score": aiScore,
      "total_messages": totalMessages,
      "total_retries": totalRetries,
      "total_score": totalScore,
      "suggestion_1": suggestion1,
      "suggestion_2": suggestion2,
      "suggestion_3": suggestion3,
    };
  }

  factory ConversationRating.fromMap(Map<String, dynamic> map) {
    return ConversationRating(
      goalScore: map["goal_score"],
      aiScore: map["ai_score"],
      totalMessages: map["total_messages"],
      totalRetries: map["total_retries"],
      totalScore: map["total_score"],
      suggestion1: map["suggestion_1"],
      suggestion2: map["suggestion_2"],
      suggestion3: map["suggestion_3"],
    );
  }
}
