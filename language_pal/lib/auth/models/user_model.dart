class UserModel {
  String? email;
  bool premiumCustomer = false; // TODO
  String learnLang;
  String useCase;
  Map<String, int> scenarioScores;

  UserModel(this.email, this.learnLang, this.useCase, this.scenarioScores);

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnLang": learnLang,
      "useCase": useCase,
      "scenarioScores": scenarioScores
    };
  }
}
