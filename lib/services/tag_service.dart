import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tag.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagService {
  final String baseUrl = 'http://uas-novel-app.c1.is/api';

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

  Future<List<Tag>> fetchTags() async {
    final response = await _authenticatedRequest((headers) => http.get(
          Uri.parse('$baseUrl/tags'),
          headers: headers,
        ));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Tag.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tags: ${response.statusCode} - ${response.body}');
    }
  }
}
