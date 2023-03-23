class UserModel {
  String email;
  bool premiumCustomer = false; // TODO
  String ownLang;
  String learnLang;
  int dailyMsgCount;

  UserModel(this.email, this.ownLang, this.learnLang, this.dailyMsgCount);

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "ownLang": ownLang,
      "learnLang": learnLang,
      "dailyMsgCount": dailyMsgCount
    };
  }
}
