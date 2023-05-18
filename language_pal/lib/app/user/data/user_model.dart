class UserModel {
  String uid;
  String email;
  bool premiumCustomer = false; // TODO
  List<String> learnTrackList;

  UserModel(this.uid, this.email, this.learnTrackList);

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid,
      map["email"] ?? "",
      (map["learnTrackList"] ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnTrackList": learnTrackList,
    };
  }

  UserModel copyWithAddedLearnTrack(String learnTrackId) {
    return UserModel(
      uid,
      email,
      [...learnTrackList, learnTrackId],
    );
  }
}
