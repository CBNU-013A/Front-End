// services/like_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LikeService {
  final String baseUrl = Platform.isAndroid
      ? 'http://${dotenv.env['BASE_URL']}:8001'
      : 'http://localhost:8001';

  Future<bool> toggleLike(
      String userId, String placeName, String token, bool isLiked) async {
    final userLikeUrl = Uri.parse('$baseUrl/api/users/$userId/likes');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    if (isLiked) {
      final response = await http.delete(
        userLikeUrl,
        headers: headers,
        body: jsonEncode({"place": placeName}),
      );
      if (response.statusCode == 200) {
        return await unlikeLocation(placeName, token);
      }
      return false;
    } else {
      final response = await http.post(
        userLikeUrl,
        headers: headers,
        body: jsonEncode({"place": placeName}),
      );
      if (response.statusCode == 201) {
        return await likeLocation(
            placeName, token); // trigger location like count increment
      }
      return false;
    }
  }

  Future<bool> isLiked(String userId, String placeName, String token) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/likes');
    final headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> likedPlaces = json.decode(response.body);
      return likedPlaces.contains(placeName);
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

  Future<bool> unlikeLocation(String placeName, String token) async {
    final url = Uri.parse('$baseUrl/api/location/$placeName/likes');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.delete(url, headers: headers);
    return response.statusCode == 200;
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
}
