import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';
import 'package:poly_app/common/logic/languages.dart';

class LearnTrackId {
  String id;
  String llCode;
  String alCode;

  LearnTrackId({
    required this.id,
    required this.llCode,
    required this.alCode,
  });

  get learnLang => LanguageModel.fromCode(llCode);
  get appLang => LanguageModel.fromCode(alCode);

  factory LearnTrackId.fromJson(Map<String, dynamic> map) {
    return LearnTrackId(
      id: map['id'],
      llCode: map['ll_code'],
      alCode: map['al_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'll_code': llCode,
      'al_code': alCode,
    };
  }
}

class LearnTrackModel {
  String id;
  List<ChapterModel> chapters;

  LearnTrackModel({
    required this.id,
    required this.chapters,
  });

  factory LearnTrackModel.fromJson(Map<String, dynamic> json, String id) {
    return LearnTrackModel(
      id: id,
      chapters: json["chapters"]
          .map((x) => ChapterModel.fromJson(x))
          .toList()
          .cast<ChapterModel>(),
    );
  }
}

class ChapterModel {
  String name;
  List<SubchapterMetadataModel> subchapters;

  ChapterModel({
    required this.name,
    required this.subchapters,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      name: json["name"],
      subchapters: json["subchapters"]
          .map((x) => SubchapterMetadataModel(
                name: x["name"],
                id: x["id"],
              ))
          .toList()
          .cast<SubchapterMetadataModel>(),
    );
  }
}
