class UserModel {
  String email;
  bool premiumCustomer = false; // TODO
  String learnLang;
  String useCase;

  UserModel(this.email, this.learnLang, this.useCase);

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
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
