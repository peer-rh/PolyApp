import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  String name;
  String? email;
  bool premiumCustomer = false; // TODO
  String ownLang;
  String learnLang;
  int dailyMsgCount;

  UserModel(
      this.name, this.email, this.ownLang, this.learnLang, this.dailyMsgCount);

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "ownLang": ownLang,
      "learnLang": learnLang,
      "dailyMsgCount": dailyMsgCount // TODO: Make this perhaps be streamed
    };
  }
}

enum Status { loading, onboarding, loaded }

class UserProvider with ChangeNotifier {
  Status status = Status.loading;
  UserModel? u;
  late String uid;

  UserProvider(User fbU) {
    uid = fbU.uid;
    getFirestore();
  }

  void getFirestore() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (!doc.exists) {
      setStatus(Status.onboarding);
    } else {
      u = UserModel(doc.get("name"), doc.get("email"), doc.get("ownLang"),
          doc.get("learnLang"), doc.get("dailyMsgCount"));
      setStatus(Status.loaded);
    }
  }

  void setUserModel(UserModel newU) {
    u = newU;
    FirebaseFirestore.instance.collection("users").doc(uid).set(newU.toMap());
    setStatus(Status.loaded);
    notifyListeners();
  }

  void setStatus(Status s) {
    status = s;
    notifyListeners();
  }

  void setOwnLang(String l) {
    if (u == null) return;
    u?.ownLang = l;
    setUserModel(u as UserModel);
  }

  void setLearnLang(String l) {
    if (u == null) return;
    u?.learnLang = l;
    setUserModel(u as UserModel);
  }

  void setName(String l) {
    if (u == null) return;
    u?.name = l;
    setUserModel(u as UserModel);
  }
}
