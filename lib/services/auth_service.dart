// services/auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class AuthService {
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email.trim(), "password": password.trim()}),
    );
    debugPrint("응답 본문: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["message"] == "로그인 성공") {
        final token = data["token"];
        final user = data["user"];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("jwt_token", token);
          await prefs.setString("userId", user["_id"] ?? "");
          await prefs.setString("userName", user["name"] ?? "");
          debugPrint('${user['_id']}');
          return true; // 로그인 성공
        }
      }
    }

    return false; // 로그인 실패
  }

// 회원가입 API
  Future<bool> register(
      String name, String email, String password, DateTime birthdate) async {
    String formattedBirthdate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(birthdate);
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "birthdate": formattedBirthdate,
      }),
    );
    debugPrint("📌api_service.dart : 회원가입 요청 데이터:");
    debugPrint("이름: $name");
    debugPrint("이메일: $email");
    debugPrint("비밀번호: $password");
    debugPrint("생년월일: $formattedBirthdate\n");

    debugPrint("[회원가입 요청] 서버 응답 코드: ${response.statusCode}");
    debugPrint("[회원가입 요청] 서버 응답 본문: ${response.body}");

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint("서버 응답 본문: ${response.body}");
      return false;
    }
  }
}
