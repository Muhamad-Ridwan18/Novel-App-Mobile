import 'dart:convert';

List<Tag> tagFromJson(String str) => List<Tag>.from(json.decode(str).map((x) => Tag.fromJson(x)));

String tagToJson(List<Tag> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Tag {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  Tag({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
