import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

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

  Future<List<Category>> fetchCategories() async {
    final response = await _authenticatedRequest((headers) => http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    ));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Category.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode} - ${response.body}');
    }
  }
}
