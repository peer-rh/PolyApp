class UserModel {
  String uid;
  String email;
  bool premiumCustomer = false; // TODO
  String learnLang;
  String useCase;

  UserModel(this.uid, this.email, this.learnLang, this.useCase);

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid,
      map["email"] ?? "",
      map["learnLang"] ?? "en",
      map["useCase"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnLang": learnLang,
      "useCase": useCase,
    };
  }
}
