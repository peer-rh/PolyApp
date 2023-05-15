import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';

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
  String title;
  List<SubchapterMetadataModel> subchapters;

  ChapterModel({
    required this.title,
    required this.subchapters,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      title: json["title"],
      subchapters: json["subchapters"]
          .map((x) => SubchapterMetadataModel(
                title: x["title"],
                id: x["id"],
              ))
          .toList()
          .cast<SubchapterMetadataModel>(),
    );
  }
}
