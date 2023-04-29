class UserModel {
  String uid;
  String email;
  bool premiumCustomer = false; // TODO
  List<String> learnLangList;
  String useCase;

  UserModel(this.uid, this.email, this.learnLangList, this.useCase);

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid,
      map["email"] ?? "",
      (map["learnLangList"] ?? []).cast<String>(),
      map["useCase"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnLangList": learnLangList,
      "useCase": useCase,
    };
  }
}
