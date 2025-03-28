import 'dart:convert';
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/pages/detailPage.dart';

class RecommendationWidget extends StatefulWidget {
  const RecommendationWidget({super.key});

  @override
  RecommendationState createState() => RecommendationState();
}

class RecommendationState extends State<RecommendationWidget> {
  Map<String, dynamic>? _recommendations;
  bool isLoading = true;
  String userName = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    //loadRecommendations(userId);
  }

  // 사용자 데이터 로드 (SharedPreferences에서 불러오기)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedUser = prefs.getString("userName");
    final String? storedUserId = prefs.getString("userId");

    if (storedUser != null && storedUserId != null) {
      debugPrint("✅ 유저 정보 로드됨: $storedUser ($storedUserId)");
      setState(() {
        userName = storedUser;
        userId = storedUserId;
        //userPreferences = storedKeywords;
      });
      await loadRecommendations(storedUserId);
    }
  }

  Future<void> loadRecommendations(String userId) async {
    try {
      final userKeywords = await fetchUserKeywords(userId);
      final allPlaces = await fetchAllPlaces();

      debugPrint("🧠 유저 키워드: $userKeywords");
      debugPrint("📍 장소 수: ${allPlaces.length}");

      final rawResult =
          getRecommendedPlaces(userKeywords, allPlaces); // ⬅️ score만 포함된 리스트

      Map<String, dynamic> fullRecommendations = {};

      for (final place in rawResult) {
        final placeId = place['_id'];
        final placeName = place['name'];
        try {
          final detail = await fetchPlaceDetail(placeName);

          final merged = Map<String, dynamic>.from(detail);

          merged['score'] = place['score'];

          fullRecommendations[placeId] = merged;
          debugPrint("📦 상세 정보: $fullRecommendations");
        } catch (e) {
          debugPrint("❌ ${place['name']} 상세 정보 불러오기 실패: $e");
        }
      }

      setState(() {
        _recommendations = fullRecommendations;
        isLoading = false;
      });
      debugPrint("✅ 추천된 장소 수: ${fullRecommendations.length}");
    } catch (e) {
      debugPrint("Error loading recommendations: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllPlaces() async {
    final response =
        await http.get(Uri.parse("http://localhost:5001/location/all"));
    if (response.statusCode == 200) {
      debugPrint("장소 로드");
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("장소 데이터 로드 실패");
    }
  }

  Future<List<String>> fetchUserKeywords(String userId) async {
    final response = await http
        .get(Uri.parse("http://localhost:5001/users/$userId/keywords"));
    if (response.statusCode == 200) {
      final List<dynamic> rawKeywords = json.decode(response.body);
      return rawKeywords.map((e) => e['text'].toString()).toList();
    } else {
      throw Exception("사용자 키워드 로드 실패");
    }
  }

  Future<Map<String, dynamic>> fetchPlaceDetail(String placeName) async {
    final response =
        await http.get(Uri.parse('http://localhost:5001/location/$placeName'));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('장소 상세 정보 불러오기 실패');
    }
  }

  List<Map<String, dynamic>> getRecommendedPlaces(
      List<String> userKeywords, List<Map<String, dynamic>> allPlaces) {
    List<Map<String, dynamic>> scoredPlaces = [];

    for (var place in allPlaces) {
      final List<dynamic> placeKeywords = place['keywords'] ?? [];
      final Set<String> placeSet =
          placeKeywords.map((e) => e.toString()).toSet();
      final Set<String> userSet = userKeywords.toSet();

      final intersection = userSet.intersection(placeSet);
      final union = userSet.union(placeSet);

      final double similarity =
          union.isEmpty ? 0.0 : intersection.length / union.length;

      if (similarity > 0.0) {
        final fullPlace = {
          '_id': place['_id'],
          'name': place['name'],
          'score': similarity.toStringAsFixed(2),
        };
        //debugPrint("✅ 추천된 장소 전체 정보: $fullPlace");
        scoredPlaces.add(fullPlace);
      }
    }

    scoredPlaces.sort(
        (a, b) => double.parse(b['score']).compareTo(double.parse(a['score'])));
    return scoredPlaces;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      debugPrint("⏳ 추천 로딩 중...");
      return const Center(child: CircularProgressIndicator());
    }

    // if (_recommendations.isEmpty) {
    //   return const Center(child: Text("추천 결과가 없습니다."));
    // }

    final places = _recommendations!.values.toList();
    return SizedBox(
      height: 320,
      child: PageView.builder(
        itemCount: _recommendations?.length,
        controller: PageController(viewportFraction: 1),
        itemBuilder: (context, index) {
          final place = places[index];

          // debugPrint(
          //     "✅ 추천 장소: ${place['name']} ${place['_id']} (유사도: ${place['score']})");
          debugPrint(place['image']?.toString());
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            child: Card(
              //elevation: 5,
              color: AppColors.paleGray,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _buildImageSection(),
                    if (place['image'] != null &&
                        place['image'] is List &&
                        place['image'].isNotEmpty) ...[
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: place['image'].length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                place['image'][index],
                                width: 300,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text("이미지 오류"),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        place['name'] ?? '정보 오류',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "유사도: ${place['score']}",
                        style: const TextStyle(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
