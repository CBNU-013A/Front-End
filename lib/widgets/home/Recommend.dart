// widgets/home/Recommend.dart

import 'dart:convert';
import 'dart:io';
import 'package:final_project/services/location_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/pages/location/DetailPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class Recommend extends StatefulWidget {
  final String userId;
  final String userName;

  const Recommend({super.key, required this.userId, required this.userName});

  @override
  RecommendState createState() => RecommendState();
}

class RecommendState extends State<Recommend> {
  final userService = UserService();
  final locationService = LocationService();
  List<dynamic> allPlaces = []; // 모든 장소 데이터

  Map<String, dynamic>? _recommendations = {};
  bool isLoading = true;
  String userName = "";
  String userId = "";
  String token = "";
  List<String> keywords = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final userData = await userService.loadUserData();
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token') ?? '';

    if (userData.isNotEmpty) {
      setState(() {
        userId = userData['userId'] ?? '';
        userName = userData['userName'] ?? '';
        token = storedToken;
        loadUserKeywords();
        loadPlaces();
      });
    } else {
      debugPrint("❌ 사용자 정보 없음 (재접속)");
    }
  }

  void loadUserKeywords() async {
    final userKeywords = await userService.fetchUserKeywords(userId);

    if (userKeywords.isNotEmpty) {
      setState(() {
        keywords = userKeywords;
      });
    }
  }

  void loadPlaces() async {
    final placeData = await locationService.fetchAllLocations();
    if (placeData.isNotEmpty) {
      setState(() {
        allPlaces = placeData;
      });
      loadRecommendations(userId);
    } else {
      debugPrint("모든 장소 정보 없음");
    }
  }

  void loadRecommendations(String userId) async {
    try {
      final rawResult =
          getRecommendedPlaces(keywords, allPlaces); // ⬅️ score만 포함된 리스트

      Map<String, dynamic> fullRecommendations = {};

      for (final place in rawResult) {
        final placeId = place['_id'];
        final placeName = place['title'];
        try {
          final detail = await locationService.fetchLocation(placeName);

          final merged = Map<String, dynamic>.from(detail);

          merged['score'] = place['score'];

          fullRecommendations[placeId] = merged;
        } catch (e) {
          debugPrint("❌ ${place['title']} 상세 정보 불러오기 실패: $e");
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

  List<Map<String, dynamic>> getRecommendedPlaces(
      List<String> userKeywords, List<dynamic> allPlaces) {
    List<Map<String, dynamic>> scoredPlaces = [];

    for (var place in allPlaces) {
      if (place['keywords'] == null || (place['keywords'] as List).isEmpty) {
        continue;
      }
      final List<dynamic> placeKeywords = place['keywords'];

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
    //debugPrint("사용자 정보 : $userId, $userName, $keywords");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.userName} 님을 위한 추천 여행지',
            style: AppTextStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            )
          else if (_recommendations == null || _recommendations!.isEmpty)
            const Center(child: Text("추천 항목이 없어요 🥲"))
          else ...[
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendations?.length ?? 0,
                controller: PageController(viewportFraction: 0.85),
                itemBuilder: (context, index) {
                  final place = _recommendations!.values.toList()[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Container(
                      height: 171,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                                bottom: Radius.circular(15),
                              ),
                              child: Image.network(
                                place['firstimage'],
                                height: 140,
                                width: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Center(
                                      child: Icon(Icons.broken_image)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 5, 16.0, 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPage(
                                            placeName: place['title'],
                                            placeId: place['_id'].toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      place['title'] ?? '정보 없음',
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
            ),
          ],
        ],
      ),
    );
  }
}
