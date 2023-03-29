class UserModel {
  String? email;
  bool premiumCustomer = false; // TODO
  String appLang;
  String learnLang;
  String useCase;
  Map<String, int> scenarioScores;

  UserModel(this.email, this.appLang, this.learnLang, this.useCase,
      this.scenarioScores);

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "appLang": appLang,
      "learnLang": learnLang,
      "useCase": useCase,
      "scenarioScores": scenarioScores
    };
  }
}
