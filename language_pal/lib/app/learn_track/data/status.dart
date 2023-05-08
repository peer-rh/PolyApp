enum UserProgressStatus {
  notStarted("notStarted"),
  inProgress("inProgress"),
  completed("completed");

  const UserProgressStatus(this.code);
  final String code;

  static UserProgressStatus fromCode(String code) {
    switch (code) {
      case "notStarted":
        return UserProgressStatus.notStarted;
      case "inProgress":
        return UserProgressStatus.inProgress;
      case "completed":
        return UserProgressStatus.completed;
      default:
        throw Exception("Invalid code");
    }
  }
}
