import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5210';

  // =========================
  // LOGIN
  // POST: /api/Auth/login
  // =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/Auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  // =========================
  // DASHBOARD OVERVIEW
  // GET: /api/Dashboard/child/{childId}/overview
  // =========================
  static Future<Map<String, dynamic>> getChildOverview(int childId) async {
    final url = Uri.parse('$baseUrl/api/Dashboard/child/$childId/overview');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load child overview');
    }
  }

  // =========================
  // CHILD ATTEMPTS
  // GET: /api/Dashboard/child/{childId}/attempts
  // =========================
  static Future<List<dynamic>> getChildAttempts(int childId) async {
    final url = Uri.parse('$baseUrl/api/Dashboard/child/$childId/attempts');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load child attempts');
    }
  }

  // =========================
  // CATEGORY PROGRESS
  // GET: /api/Dashboard/child/{childId}/categories
  // =========================
  static Future<List<dynamic>> getCategoryProgress(int childId) async {
    final url = Uri.parse('$baseUrl/api/Dashboard/child/$childId/categories');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load category progress');
    }
  }

  // =========================
  // UPLOAD SPEECH ATTEMPT
  // POST: /api/Attempts
  // multipart/form-data
  // =========================
  static Future<Map<String, dynamic>> uploadAttempt({
    required File audioFile,
    required int childId,
    required int contentItemId,
  }) async {
    final url = Uri.parse('$baseUrl/api/Attempts');

    final request = http.MultipartRequest('POST', url);

    request.fields['ChildId'] = childId.toString();
    request.fields['ContentItemId'] = contentItemId.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'File',
        audioFile.path,
        filename: audioFile.path.split('/').last,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  // =========================
  // ALL CONTENT ITEMS
  // GET: /api/ContentItems
  // =========================
  static Future<List<dynamic>> getAllContentItems() async {
    final url = Uri.parse('$baseUrl/api/ContentItems');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load content items');
    }
  }

  // =========================
  // CONTENT ITEMS BY CATEGORY
  // GET: /api/ContentItems/category/{categoryId}
  // =========================
  static Future<List<dynamic>> getContentItemsByCategory(int categoryId) async {
    final url = Uri.parse('$baseUrl/api/ContentItems/category/$categoryId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load category content items');
    }
  }

  // =========================
  // CATEGORIES
  // GET: /api/Categories
  // =========================
  static Future<List<dynamic>> getCategories() async {
    final url = Uri.parse('$baseUrl/api/Categories');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // =========================
  // CHILDREN BY PARENT
  // GET: /api/Children/parent/{parentId}
  // =========================
  static Future<List<dynamic>> getChildrenByParent(int parentId) async {
    final url = Uri.parse('$baseUrl/api/Children/parent/$parentId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load children');
    }
  }

  // =========================
  // CHILD BY ID
  // GET: /api/Children/{id}
  // =========================
  static Future<Map<String, dynamic>> getChildById(int childId) async {
    final url = Uri.parse('$baseUrl/api/Children/$childId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load child');
    }
  }

  // =========================
  // REGISTER PARENT
  // POST: /api/Parents
  // =========================
  static Future<Map<String, dynamic>> registerParent({
    required String name,
    required String email,
    required String password,
    required String relationToChild,
    required String childName,
    required int childAge,
    required String childGender,
  }) async {
    final url = Uri.parse('$baseUrl/api/Parents');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'relationToChild': relationToChild,
        'children': [
          {'name': childName, 'age': childAge, 'gender': childGender},
        ],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}
