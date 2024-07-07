import 'dart:convert';
import 'tag.dart';

Novel novelFromJson(String str) => Novel.fromJson(json.decode(str));

String novelToJson(Novel data) => json.encode(data.toJson());

class Novel {
  bool success;
  String message;
  List<NovelElement> novels;

  Novel({
    required this.success,
    required this.message,
    required this.novels,
  });

  factory Novel.fromJson(Map<String, dynamic> json) => Novel(
        success: json["success"],
        message: json["message"],
        novels: List<NovelElement>.from(json["novels"].map((x) => NovelElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "novels": List<dynamic>.from(novels.map((x) => x.toJson())),
      };
}

class NovelElement {
  int id;
  String title;
  String description;
  Map<String, dynamic> author;
  int categoryId;
  String coverImage;
  DateTime publishedDate;
  String synopsis;
  DateTime createdAt;
  DateTime updatedAt;
  List<Tag> tags;

  NovelElement({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.categoryId,
    required this.coverImage,
    required this.publishedDate,
    required this.synopsis,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
  });

  factory NovelElement.fromJson(Map<String, dynamic> json) => NovelElement(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        author: json["author"], 
        categoryId: json["category_id"],
        coverImage: json["cover_image"],
        publishedDate: DateTime.parse(json["published_date"]),
        synopsis: json["synopsis"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        tags: List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "author": author, 
        "category_id": categoryId,
        "cover_image": coverImage,
        "published_date":
            "${publishedDate.year.toString().padLeft(4, '0')}-${publishedDate.month.toString().padLeft(2, '0')}-${publishedDate.day.toString().padLeft(2, '0')}",
        "synopsis": synopsis,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "tags": List<dynamic>.from(tags.map((x) => x.toJson())),
      };
}
