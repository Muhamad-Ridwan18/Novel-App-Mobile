import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/novel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NovelService {
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

  Future<Novel> fetchNovels() async {
    final response = await _authenticatedRequest((headers) => http.get(
      Uri.parse('$baseUrl/novels'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return Novel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load novels');
    }
  }

  Future<Novel> fetchLastNovels() async {
    final response = await _authenticatedRequest((headers) => http.get(
      Uri.parse('$baseUrl/lastNovel'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return Novel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load novels');
    }
  }

  Future<NovelElement> fetchNovelById(int id) async {
    final response = await _authenticatedRequest((headers) => http.get(
      Uri.parse('$baseUrl/novels/$id'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return NovelElement.fromJson(jsonDecode(response.body)['novel']);
    } else {
      throw Exception('Failed to load novel');
    }
  }

  Future<void> createNovel(NovelElement novel) async {
    final response = await _authenticatedRequest((headers) => http.post(
      Uri.parse('$baseUrl/novels'),
      headers: headers,
      body: jsonEncode({
        ...novel.toJson(),
        'tags': novel.tags.map((tag) => tag.id).toList(),
      }),
    ));

    if (response.statusCode != 201) {
      throw Exception('Failed to create novel: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateNovel(NovelElement novel) async {
    final response = await http.put(
      Uri.parse('$baseUrl/novels/${novel.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonEncode({
        ...novel.toJson(),
        'tags': novel.tags.map((tag) => tag.id).toList(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update novel: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteNovel(int id) async {
    final response = await _authenticatedRequest((headers) => http.delete(
      Uri.parse('$baseUrl/novels/$id'),
      headers: headers,
    ));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete novel: ${response.statusCode} - ${response.body}');
    }
  }

  Future<NovelElement> fetchNovelByAuthorId(int id) async {
   final response = await _authenticatedRequest((headers) => http.get(
      Uri.parse('$baseUrl/getNovelByAuthor/$id'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      return NovelElement.fromJson(jsonDecode(response.body)['novel']);
    } else {
      throw Exception('Failed to load novel');
    }
  }
    
}
