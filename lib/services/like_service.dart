// services/like_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LikeService {
  final String baseUrl = Platform.isAndroid
      ? 'http://${dotenv.env['BASE_URL']}:8001'
      : 'http://localhost:8001';

  Future<bool> toggleLike(
      String userId, String placeId, String token, bool isLiked) async {
    final userLikeUrl = Uri.parse('$baseUrl/api/users/$userId/likes');

    if (isLiked) {
      final response = await http.delete(
        userLikeUrl,
        body: jsonEncode({"locationId": placeId}),
      );
      return response.statusCode == 200;
    } else {
      final response = await http.post(
        userLikeUrl,
        body: jsonEncode({"locationId": placeId}),
      );
      return response.statusCode == 200;
    }
  }

  //사용자 좋아요 목록 반환
  Future<bool> loadUserLikePlace(
      String userId, String placeId, String token) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/users/$userId/likes'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> likedPlaces = data['likes'];
      return likedPlaces.any((place) => place['_id'] == placeId);
    }
    return false;
  }

  Future<bool> likeLocation(String placeName, String token) async {
    final url = Uri.parse('$baseUrl/api/location/$placeName/likes');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers);
    return response.statusCode == 201;
  }

  Future<int?> getLocationLikeCount(String placeName, String token) async {
    final url = Uri.parse('$baseUrl/api/location/$placeName/likes');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['likeCount'] as int?;
    }
    return null;
  }

  // 좋아요 버튼 위젯
  Widget likeButton({
    required String userId,
    required String placeId,
    required String token,
    required void Function(bool isLiked) onLikeChanged,
  }) {
    return FutureBuilder<bool>(
      future: loadUserLikePlace(userId, placeId, token),
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.black,
          ),
          onPressed: () async {
            final success = await toggleLike(userId, placeId, token, isLiked);
            if (success) {
              onLikeChanged(!isLiked);
            } else {}
          },
        );
      },
    );
  }
}
