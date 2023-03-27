class UserModel {
  String email;
  bool premiumCustomer = false; // TODO
  String ownLang;
  String learnLang;
  String useCase;

  UserModel(this.email, this.ownLang, this.learnLang, this.useCase);

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "ownLang": ownLang,
      "learnLang": learnLang,
      "useCase": useCase
    };
  }
}
