// services/sentiment_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SentimentService {
  // 백엔드 REST API 엔드포인트로 변경
  final String apiUrl = 'http://localhost:8001/api/predict/';

  // 입력 텍스트를 그대로 body의 text 필드로 전송하고, 응답 JSON 전체를 반환
  Future<Map<String, dynamic>?> analyzeSentiment(String text) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        // 백엔드에서 내려준 JSON을 그대로 반환
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return decoded;
      } else {
        debugPrint('❌ 예측 요청 실패: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 예측 요청 오류: $e');
      return null;
    }
  }
}
