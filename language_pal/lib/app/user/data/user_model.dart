import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poly_app/app/learn_track/data/learn_track_model.dart';

get today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class UserModel {
  String uid;
  String email;
  bool premiumCustomer = false; // TODO
  List<LearnTrackId> learnTrackList;
  int activeLearnTrackIndex;
  List<DateTime> lastActiveDates;
  get activeLearnTrack => learnTrackList[activeLearnTrackIndex];
  get todayAlreadyAdded =>
      lastActiveDates.isNotEmpty && lastActiveDates.last == today;

  UserModel(
      this.uid, this.email, this.learnTrackList, this.activeLearnTrackIndex,
      {this.lastActiveDates = const []});

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid,
      map["email"] ?? "",
      (map["learnTrackList"]
              .map<LearnTrackId>((e) => LearnTrackId.fromJson(e))
              .toList() ??
          []),
      map["activeLearnTrackIndex"] ?? 0,
      lastActiveDates: map["lastActiveDates"]
              ?.map<DateTime>((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "learnTrackList": learnTrackList.map((e) => e.toJson()).toList(),
      "activeLearnTrackIndex": activeLearnTrackIndex,
      "lastActiveDates":
          lastActiveDates.map((e) => Timestamp.fromDate(e)).toList(),
    };
  }

  UserModel copyWith({
    String? email,
    List<LearnTrackId>? learnTrackList,
    int? activeLearnTrackIndex,
    List<DateTime>? lastActiveDates,
  }) {
    return UserModel(
      uid,
      email ?? this.email,
      learnTrackList ?? this.learnTrackList,
      activeLearnTrackIndex ?? this.activeLearnTrackIndex,
      lastActiveDates: lastActiveDates ?? this.lastActiveDates,
    );
  }

  UserModel copyWithAddedLearnTrack(LearnTrackId learnTrackId) {
    return copyWith(learnTrackList: [...learnTrackList, learnTrackId]);
  }

  UserModel copyWithAddedLastActiveDate(DateTime date) {
    date = DateTime(date.year, date.month, date.day);
    if (lastActiveDates.contains(date)) return this;
    return copyWith(lastActiveDates: [...lastActiveDates, date]);
  }
}
