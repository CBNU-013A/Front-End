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
      //debugPrint("✅ 유저 정보 로드됨: $storedUser ($storedUserId)");
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

      //debugPrint("🧠 유저 키워드: $userKeywords");
      //debugPrint("📍 장소 수: ${allPlaces.length}");

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
          //debugPrint("📦 상세 정보: $fullRecommendations");
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
        await http.get(Uri.parse("http://localhost:8001/api/location/all"));
    if (response.statusCode == 200) {
      //debugPrint("장소 로드");
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("장소 데이터 로드 실패");
    }
  }

  Future<List<String>> fetchUserKeywords(String userId) async {
    final response = await http
        .get(Uri.parse("http://localhost:8001/api/users/$userId/keywords"));
    if (response.statusCode == 200) {
      final List<dynamic> rawKeywords = json.decode(response.body);
      return rawKeywords.map((e) => e['name'].toString()).toList();
    } else {
      throw Exception("사용자 키워드 로드 실패");
    }
  }

  Future<Map<String, dynamic>> fetchPlaceDetail(String placeName) async {
    final response = await http
        .get(Uri.parse('http://localhost:8001/api/location/$placeName'));

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

      // Map<String, int> 형태로 변환: {'가격': 20, '청결': 12, ...}
      final Map<String, int> placeKeywordMap = {
        for (var k in placeKeywords)
          if (k is Map<String, dynamic> &&
              k['name'] != null &&
              k['sentiment'] != null &&
              k['sentiment']['total'] != null)
            k['name'].toString(): k['sentiment']['total'] ?? 0
      };

      // 사용자 키워드 중 이 장소에 포함된 키워드의 total 점수를 합산
      double score = 0.0;

      for (String keyword in userKeywords) {
        if (placeKeywordMap.containsKey(keyword)) {
          score += placeKeywordMap[keyword]!.toDouble();
        }
      }

      if (score > 0) {
        scoredPlaces.add({
          '_id': place['_id'],
          'name': place['name'],
          'score': score.toStringAsFixed(2),
        });
      }
    }

    scoredPlaces.sort(
      (a, b) => double.parse(b['score']).compareTo(double.parse(a['score'])),
    );

    return scoredPlaces;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      //debugPrint("⏳ 추천 로딩 중...");
      return const Center(child: CircularProgressIndicator());
    }
    if (_recommendations == null || _recommendations!.isEmpty) {
      return const Center(child: Text("추천 항목이 없어요 🥲"));
    }
    final places = _recommendations!.values.toList();
    if (places.isNotEmpty) {
      return SizedBox(
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _recommendations?.length,
          controller: PageController(viewportFraction: 0.85),
          itemBuilder: (context, index) {
            final place = places[index];

            //debugPrint(place['image']?.toString());
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Container(
                height: 171,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0), // 🔥 위쪽 여백 8px
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                            bottom: Radius.circular(15)),
                        child: Image.network(
                          place['image'][0],
                          height: 140,
                          width: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 120,
                            color: Colors.grey[300],
                            child:
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 5, 16.0, 5),
                      child: Row(
                        // ✅ Row 추가
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            // ✅ Expanded 추가해서 Text가 왼쪽부터 시작
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                      place: place['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                place['name'] ?? '정보 없음',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox(child: Text("추천 항목이 없어요🥲"));
    }
  }
}
