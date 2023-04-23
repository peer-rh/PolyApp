class UserModel {
  String uid;
  String email;
  bool premiumCustomer = false; // TODO
  List<String> learnLangList;
  Map<String, Map<String, int>> bestScores;
  String useCase;

  UserModel(
      this.uid, this.email, this.learnLangList, this.useCase, this.bestScores);

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid,
      map["email"] ?? "",
      (map["learnLangList"] ?? []).cast<String>(),
      map["useCase"] ?? "",
      map["bestScores"] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnLangList": learnLangList,
      "useCase": useCase,
      "bestScores": bestScores,
    };
  }
}
