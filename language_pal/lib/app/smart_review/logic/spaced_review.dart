import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/common/util.dart';
import 'package:poly_app/common/logic/abilities.dart';

final spacedReviewProvider = ChangeNotifierProvider((ref) {
  final userTrackDoc = ref.watch(userLearnTrackDocProvider);
  final spacedReview = SpacedReviewProvider(userTrackDoc);

  ref.listen(cantTalkProvider, (_, newVal) => spacedReview.cantTalk = newVal);
  ref.listen(
      cantListenProvider, (_, newVal) => spacedReview.cantListen = newVal);
});

class SpacedReviewProvider extends ChangeNotifier {
  List<SpacedReviewItem> _items = [];
  List<String> _allWords = [];
  final DocumentReference userTrackDoc;

  bool _cantTalk = false;
  bool _cantListen = false;

  set cantTalk(bool newVal) {
    _cantTalk = newVal;
    _currentItem = _getNextItem();
    notifyListeners();
  }

  set cantListen(bool newVal) {
    _cantListen = newVal;
    _currentItem = _getNextItem();
    notifyListeners();
  }

  SpacedReviewProvider(this.userTrackDoc) {
    _load();
  }

  InputStep? _currentItem;

  InputStep? get currentItem {
    if (_currentItem == null && _items.isNotEmpty) {
      _currentItem = _getNextItem();
    }
    return _currentItem;
  }

  InputStep _getNextItem() {
    InputType type =
        InputType.values[Random().nextInt(InputType.values.length)];
    final item = _items.first;
    if (_cantTalk && type == InputType.pronounce) {
      type = InputType.compose;
    }
    if (_cantListen && type == InputType.listen) {
      type = InputType.write;
    }
    if (type == InputType.compose && item.learnLang.split(" ").length < 2) {
      type = InputType.write;
    }

    return switch (type) {
      InputType.compose => InputStep(
            prompt: item.appLang,
            answer: item.learnLang,
            type: type,
            options: [
              ...item.learnLang.split(" "),
              ...generateRandomIntegers(6, _allWords.length)
                  .map((e) => _allWords[e])
                  .where((e) => item.learnLang.split(" ").contains(e))
                  .take(6)
                  .toList()
            ]),
      InputType.listen || InputType.select => InputStep(
            prompt: item.appLang,
            answer: item.learnLang,
            type: type,
            options: [
              item.learnLang,
              ...generateRandomIntegers(4, _items.length)
                  .map((e) => _items[e].learnLang)
                  .where((e) => item.learnLang != e)
                  .take(3)
                  .toList()
            ]),
      InputType.pronounce || InputType.write => InputStep(
          prompt: item.learnLang,
          answer: item.appLang,
          type: type,
        ),
    };
  }

  void _load() async {
    final doc =
        await userTrackDoc.collection("spaced_review").doc("vocab").get();
    if (doc.data() != null) {
      final data = doc.data()!["items"] as List;
      _items.addAll(data.map((e) => SpacedReviewItem(
            DateTime.parse(e["next_review"]),
            e["learn_lang"],
            e["app_lang"],
            e["days_to_add"],
          )));
      _items.sort((a, b) => a.nextReview.compareTo(b.nextReview));
      _allWords =
          _items.expand((element) => element.learnLang.split(" ")).toList();
    }
    notifyListeners();
  }

  void _save() {
    final data = _items.map((e) => {
          "next_review": e.nextReview.toIso8601String(),
          "learn_lang": e.learnLang,
          "app_lang": e.appLang,
          "days_to_add": e.daysToAdd,
        });
    userTrackDoc.collection("spaced_review").doc("vocab").set({"items": data});
  }
}

class SpacedReviewItem {
  DateTime nextReview;
  int daysToAdd;
  String learnLang;
  String appLang;

  SpacedReviewItem(
      this.nextReview, this.learnLang, this.appLang, this.daysToAdd);
}

int getNextDaysToAdd(int prev) {
  return switch (prev) { 1 => 3, 3 => 7, 7 => 14, 14 => 30, 30 => 30, _ => 1 };
}
