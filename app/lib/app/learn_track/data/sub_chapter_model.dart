import 'package:poly_app/app/learn_track/data/lesson_model.dart';

class SubchapterMetadataModel {
  String name;
  String id;

  SubchapterMetadataModel({
    required this.name,
    required this.id,
  });
}

class SubchapterModel {
  String id;
  String name;
  List<LessonMetadataModel> lessons;
  String description;

  SubchapterModel({
    required this.id,
    required this.name,
    required this.lessons,
    required this.description,
  });

  factory SubchapterModel.fromJson(Map<String, dynamic> json, String id) =>
      SubchapterModel(
        id: id,
        name: json["name"],
        lessons: json["lessons"]
            .map((x) => LessonMetadataModel(
                  id: x["id"],
                  name: x["name"],
                  type: x["type"],
                ))
            .toList()
            .cast<LessonMetadataModel>(),
        description: json["description"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "lessons": lessons
            .map((x) => {
                  "name": x.name,
                  "id": x.id,
                  "type": x.type,
                })
            .toList(),
        "description": description,
      };
}
