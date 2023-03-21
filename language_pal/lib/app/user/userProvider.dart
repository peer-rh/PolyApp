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
      "dailyMsgCount": dailyMsgCount
    };
  }
}
