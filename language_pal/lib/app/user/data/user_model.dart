import 'package:poly_app/app/learn_track/data/learn_track_model.dart';

class UserModel {
  String uid;
  String email;
  bool premiumCustomer = false; // TODO
  List<LearnTrackId> learnTrackList;
  int activeLearnTrackIndex;
  get activeLearnTrack => learnTrackList[activeLearnTrackIndex];

  UserModel(
      this.uid, this.email, this.learnTrackList, this.activeLearnTrackIndex);

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid,
      map["email"] ?? "",
      (map["learnTrackList"]
              .map<LearnTrackId>((e) => LearnTrackId.fromJson(e))
              .toList() ??
          []),
      map["activeLearnTrackIndex"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnTrackList": learnTrackList.map((e) => e.toJson()).toList(),
      "activeLearnTrackIndex": activeLearnTrackIndex,
    };
  }

  UserModel copyWithAddedLearnTrack(LearnTrackId learnTrackId) {
    activeLearnTrackIndex = learnTrackList.length;
    return UserModel(
      uid,
      email,
      [...learnTrackList, learnTrackId],
      activeLearnTrackIndex,
    );
  }

  UserModel copyWithActiveLearnTrackIndex(int index) {
    return UserModel(
      uid,
      email,
      learnTrackList,
      index,
    );
  }
}
