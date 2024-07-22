import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterService {
  static const String baseUrl = 'http://uas-novel-app.c1.is/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<http.Response> _authenticatedRequest(Future<http.Response> Function(Map<String, String>) request) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token is null');
    }
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    return await request(headers);
  }

  // Fetch all chapters by novel ID
  Future<List<ChapterElement>> fetchChaptersByNovelId(int novelId) async {
    final response = await _authenticatedRequest((headers) => http.get(
          Uri.parse('$baseUrl/chapters/novel/$novelId'),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<ChapterElement> chapters =
          body.map((dynamic item) => ChapterElement.fromJson(item)).toList();
      return chapters;
    } else {
      throw Exception('Failed to load chapters: ${response.statusCode} - ${response.body}');
    }
  }

  // Fetch all chapters
  Future<Chapter> fetchChapters() async {
    final response = await _authenticatedRequest((headers) => http.get(
          Uri.parse('$baseUrl/chapters'),
          headers: headers,
        ));
    if (response.statusCode == 200) {
      return Chapter.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load chapters: ${response.statusCode} - ${response.body}');
    }
  }

  // Fetch a single chapter by ID
  Future<ChapterElement> fetchChapterById(int id) async {
    final response = await _authenticatedRequest((headers) => http.get(
          Uri.parse('$baseUrl/chapters/$id'),
          headers: headers,
        ));
    if (response.statusCode == 200) {
      return ChapterElement.fromJson(jsonDecode(response.body)['chapter']);
    } else {
      throw Exception('Failed to load chapter: ${response.statusCode} - ${response.body}');
    }
  }

  // Create a new chapter
  Future<void> createChapter(ChapterElement chapter) async {
    final response = await _authenticatedRequest((headers) => http.post(
          Uri.parse('$baseUrl/chapters'),
          headers: headers,
          body: jsonEncode(chapter.toJson()),
        ));
    if (response.statusCode != 201) {
      throw Exception('Failed to create chapter: ${response.statusCode} - ${response.body}');
    }
  }

  // Update an existing chapter
  Future<void> updateChapter(ChapterElement chapter) async {
    final response = await _authenticatedRequest((headers) => http.put(
          Uri.parse('$baseUrl/chapters/${chapter.id}'),
          headers: headers,
          body: jsonEncode(chapter.toJson()),
        ));
    if (response.statusCode != 200) {
      throw Exception('Failed to update chapter: ${response.statusCode} - ${response.body}');
    }
  }

  // Delete a chapter
  Future<void> deleteChapter(int id) async {
    final response = await _authenticatedRequest((headers) => http.delete(
          Uri.parse('$baseUrl/chapters/$id'),
          headers: headers,
        ));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete chapter: ${response.statusCode} - ${response.body}');
    }
  }
}
