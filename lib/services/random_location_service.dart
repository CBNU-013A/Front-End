import 'dart:convert';
import 'package:http/http.dart' as http;

class RandomLocationService {
  static const String baseUrl = 'http://localhost:8001';

  /// 랜덤 장소 10개 가져오기
  static Future<List<dynamic>> getRandomLocations() async {
    try {
      final url = Uri.parse('$baseUrl/api/location/random');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as List<dynamic>;
      } else {
        print('Random locations API error: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching random locations: $e');
      return [];
    }
  }
}
