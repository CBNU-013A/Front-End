// services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class UserService {
  Future<List<String>> fetchUserKeywords(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/users/$userId/keywords'));

    if (response.statusCode == 200) {
      final List<dynamic> fetchedKeywords = json.decode(response.body);
      return fetchedKeywords.map((k) => k['name'].toString()).toList();
    } else {
      throw Exception('🚨 사용자 키워드 불러오기 실패: ${response.statusCode}');
    }
  }

  // 로그아웃: 모든 유저 관련 정보 제거
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userName");
    await prefs.remove("userPreferences");
  }
}
