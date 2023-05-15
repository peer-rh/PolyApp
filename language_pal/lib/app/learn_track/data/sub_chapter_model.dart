import 'package:poly_app/app/learn_track/data/lesson_model.dart';

class SubchapterMetadataModel {
  String title;
  String id;

  SubchapterMetadataModel({
    required this.title,
    required this.id,
  });
}

class SubchapterModel {
  String id;
  String title;
  List<LessonMetadataModel> lessons;
  String description;

  SubchapterModel({
    required this.id,
    required this.title,
    required this.lessons,
    required this.description,
  });

  factory SubchapterModel.fromJson(Map<String, dynamic> json, String id) =>
      SubchapterModel(
        id: id,
        title: json["title"],
        lessons: json["lessons"]
            .map((x) => LessonMetadataModel(
                  id: x["id"],
                  title: x["title"],
                  type: x["type"],
                ))
            .toList()
            .cast<LessonMetadataModel>(),
        description: json["description"] ?? "",
      );
}
