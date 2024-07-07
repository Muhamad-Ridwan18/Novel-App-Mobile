// To parse this JSON data, do
//
//     final chapter = chapterFromJson(jsonString);

import 'dart:convert';

Chapter chapterFromJson(String str) => Chapter.fromJson(json.decode(str));

String chapterToJson(Chapter data) => json.encode(data.toJson());

class Chapter {
    List<ChapterElement> chapters;

    Chapter({
        required this.chapters,
    });

    factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        chapters: List<ChapterElement>.from(json["chapters"].map((x) => ChapterElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "chapters": List<dynamic>.from(chapters.map((x) => x.toJson())),
    };
}

class ChapterElement {
    int id;
    int novelId;
    String title;
    String content;
    int chapterNumber;
    DateTime publishedDate;
    DateTime createdAt;
    DateTime updatedAt;

    ChapterElement({
        required this.id,
        required this.novelId,
        required this.title,
        required this.content,
        required this.chapterNumber,
        required this.publishedDate,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ChapterElement.fromJson(Map<String, dynamic> json) => ChapterElement(
        id: json["id"],
        novelId: json["novel_id"],
        title: json["title"],
        content: json["content"],
        chapterNumber: json["chapter_number"],
        publishedDate: DateTime.parse(json["published_date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "novel_id": novelId,
        "title": title,
        "content": content,
        "chapter_number": chapterNumber,
        "published_date": "${publishedDate.year.toString().padLeft(4, '0')}-${publishedDate.month.toString().padLeft(2, '0')}-${publishedDate.day.toString().padLeft(2, '0')}",
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };

  
}
