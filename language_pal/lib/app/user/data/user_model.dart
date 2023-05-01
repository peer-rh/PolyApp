class UserModel {
  String uid;
  String email;
  bool premiumCustomer = false; // TODO
  List<String> learnTrackList;
  String useCase;

  UserModel(this.uid, this.email, this.learnTrackList, this.useCase);

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid,
      map["email"] ?? "",
      (map["learnTrackList"] ?? []).cast<String>(),
      map["useCase"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnTrackList": learnTrackList,
      "useCase": useCase,
    };
  }
}
