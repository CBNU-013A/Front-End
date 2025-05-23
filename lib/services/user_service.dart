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

  // 사용자 정보 가져오기 (Shared Preference)
  Future<Map<String, String?>> loadUserData() async {
    debugPrint("loadUserData 호출됨");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      debugPrint("SharedPreferences에서 토큰을 찾을 수 없음");
      return {};
    }

    final userId = prefs.getString('userId');
    final userName = prefs.getString('userName');

    debugPrint("loadUserData(): userId=$userId, userName=$userName");

    return {
      'userId': userId,
      'userName': userName,
    };
  }

  // 로그아웃: 모든 유저 관련 정보 제거
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userName");
    await prefs.remove("userPreferences");
  }
}
