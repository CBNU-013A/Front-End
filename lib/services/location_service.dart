// services/location_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class LocationService {
  Future<Map<String, dynamic>> fetchLocationWithKeywords(
      String locationId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/auth/location/$locationId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load location data');
    }
  }
}
