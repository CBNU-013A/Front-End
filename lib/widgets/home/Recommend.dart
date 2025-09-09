// widgets/home/Recommend.dart

import 'dart:convert';
import 'dart:io';
import 'package:final_project/services/location_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/services/random_location_service.dart';
import 'package:final_project/services/like_service.dart';
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
  final likeService = LikeService();
  List<dynamic> allPlaces = []; // 모든 장소 데이터

  Map<String, dynamic>? _recommendations = {};
  bool isLoading = true;
  String userName = "";
  String userId = "";
  String token = "";
  List<String> keywords = [];
  List<dynamic> _randomLocations = [];

  List<dynamic> likedPlaces = [];
  bool hasLikes = false;
  final Set<String> _likedIds = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadLikes();
    loadRandomLocations();
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
      });
      loadUserKeywords();
      loadPlaces();
      _loadLikes();
    } else {
      debugPrint("❌ 사용자 정보 없음 (재접속)");
    }
  }

  Future<void> _loadLikes() async {
    if (userId.isEmpty) return;
    try {
      final likes = await likeService.loadUserLikePlaces(userId, token);
      setState(() {
        likedPlaces = likes ?? [];
        hasLikes = likedPlaces.isNotEmpty;
        _likedIds
          ..clear()
          ..addAll(
              likedPlaces.map((e) => (e['_id'] ?? e['id'] ?? '').toString()));
      });
    } catch (e) {
      debugPrint('❌ 좋아요 목록 불러오기 실패: $e');
      setState(() {
        likedPlaces = [];
        hasLikes = false;
      });
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

  void loadRandomLocations() async {
    try {
      final list = await RandomLocationService.getRandomLocations();
      setState(() {
        _randomLocations = list;
      });
    } catch (e) {
      debugPrint("❌ 랜덤 여행지 불러오기 실패: $e");
    }
  }

  Future<void> _toggleLike(Map<String, dynamic> place) async {
    final pid = (place['_id'] ?? place['id'] ?? '').toString();
    if (pid.isEmpty || userId.isEmpty) return;

    try {
      if (_likedIds.contains(pid)) {
        final ok = await likeService.removeUserLike(userId, pid);
        if (ok) {
          setState(() {
            _likedIds.remove(pid);
          });
        }
      } else {
        final ok = await likeService.addUserLike(userId, pid);
        if (ok) {
          setState(() {
            _likedIds.add(pid);
          });
        }
      }
    } catch (e) {
      debugPrint('❌ 좋아요 토글 실패: $e');
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            )
          else if (hasLikes) ...[
            Text(
              "${widget.userName} 님을 위한 추천 여행지",
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (_recommendations == null || _recommendations!.isEmpty)
              const Center(
                child: Text(
                  "추천된 여행지가 아직 없습니다.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
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
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pik 추천 인기 여행지",
                  style: AppTextStyles.sectionTitle,
                ),
                TextButton.icon(
                  onPressed: loadRandomLocations,
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                  label:
                      const Text('새로고침', style: TextStyle(color: Colors.grey)),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 210,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _randomLocations.length,
                controller: PageController(viewportFraction: 0.85),
                itemBuilder: (context, index) {
                  final place =
                      Map<String, dynamic>.from(_randomLocations[index]);
                  final pid = (place['_id'] ?? place['id'] ?? '').toString();
                  final isLiked = _likedIds.contains(pid);
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: _RandomPlaceCard(
                      place: place,
                      isLiked: isLiked,
                      onLike: () => _toggleLike(place),
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

class _RandomPlaceCard extends StatelessWidget {
  const _RandomPlaceCard({
    required this.place,
    required this.isLiked,
    required this.onLike,
  });
  final Map<String, dynamic> place;
  final bool isLiked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
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
            child: _SquareImage(
              url: (place['firstimage'] ?? '').toString(),
              size: 140,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 6, 12.0, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            placeName: (place['title'] ?? '정보 없음').toString(),
                            placeId: (place['_id'] ?? '').toString(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      (place['title'] ?? '정보 없음').toString(),
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
                const SizedBox(width: 8),
                InkWell(
                  onTap: onLike,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isLiked ? AppColors.mainGreen : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareImage extends StatelessWidget {
  const _SquareImage({required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder();
    }
    return Image.network(
      url,
      height: size,
      width: size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: size,
          width: size,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: size,
      width: size,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Text(
        'No Image',
        style: TextStyle(
            color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
