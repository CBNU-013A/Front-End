// services/review_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReviewService {
  final String baseUrl = Platform.isAndroid
      ? 'http://${dotenv.env['BASE_URL']}:8001'
      : 'http://localhost:8001';

  Future<Map<String, dynamic>> fetchReviewsByLocation(
      String locationId, String token) async {
    final queryParameters = <String, String>{};

    final uri = Uri.parse('$baseUrl/api/review/location/$locationId')
        .replace(queryParameters: queryParameters);

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return {
        'reviews': List<Map<String, dynamic>>.from(body['reviews']),
        'myReview': body['myReview'] as Map<String, dynamic>?,
      };
    } else {
      throw Exception('리뷰 목록 조회 실패');
    }
  }

  Future<bool> createReview(
      String placeId, String content, String token) async {
    final url = Uri.parse('$baseUrl/api/review/$placeId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
      }),
    );

    return response.statusCode == 201;
  }

  Future<bool> deleteReview(String reviewId, String token) async {
    final url = Uri.parse('$baseUrl/api/review/$reviewId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> updateReview(
      String reviewId, String newContent, String token) async {
    final url = Uri.parse('$baseUrl/api/review/$reviewId');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': newContent,
      }),
    );

    return response.statusCode == 200;
  }
}
