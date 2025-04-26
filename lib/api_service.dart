import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:8001/api/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    debugPrint("📌 서버 응답 코드: ${response.statusCode}");
    debugPrint("📌 서버 응답 본문: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body); // 🔹 JSON 데이터 반환
    } else {
      return null; // 로그인 실패 시 null 반환
    }
  }

  final String baseUrl = "http://localhost:8001/api/auth"; // 서버 포트 확인

  // 회원가입 API
  Future<bool> register(
      String name, String email, String password, DateTime birthdate) async {
    String formattedBirthdate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(birthdate);
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
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

  //Location-keywords
  Future<Map<String, dynamic>> fetchLocationWithKeywords(String locationId) async {
    final response = await http.get(Uri.parse('$baseUrl/location/$locationId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load location data');
    }
  }
}
