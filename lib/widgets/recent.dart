// widgets/recent.dart
import 'dart:convert';
import 'dart:io';
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/pages/location/detailPage.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';
    
class RecentSearchWidget extends StatefulWidget {
  const RecentSearchWidget({super.key});

  @override
  RecentSearchState createState() => RecentSearchState();
}

class RecentSearchState extends State<RecentSearchWidget> {
  List<String>? _recentSearches;
  List<Map<String, dynamic>>? allPlaces;
  bool isLoading = true;
  String userName = "";
  String userId = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _timer = Timer.periodic(const Duration(seconds: 100), (timer) {
    //   _loadUserData(); // 🔥 5초마다 최근 검색 새로고침
    // });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 🔥 화면 나갈 때 타이머 정리 필수
    super.dispose();
  }

// 사용자 데이터 로드 (SharedPreferences에서 불러오기)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedUser = prefs.getString("userName");
    final String? storedUserId = prefs.getString("userId");

    if (storedUserId == null || storedUserId.isEmpty) {
      debugPrint("❌ 저장된 userId가 없습니다. 로그인 상태를 확인하세요.");
      return;
    }

    if (storedUser != null) {
      debugPrint("✅ 유저 정보 로드됨: $storedUser ($storedUserId)");
      setState(() {
        userName = storedUser;
        userId = storedUserId;
      });
      debugPrint("🔍 가져올 userId: $userId");
      await fetchUserRecentSearches(userId);
      final places = await fetchAllPlaces();
      setState(() {
        allPlaces = places;
      });
    }
  }

  // 특정 사용자의 최근 검색 기록 가져오기
  Future<void> fetchUserRecentSearches(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/recentsearch'),
      );
      if (response.statusCode == 200) {
        debugPrint("✅ 사용자 최근 검색 기록 로드 성공");
        final List<dynamic> data = json.decode(response.body);

        final List<String> names = List<String>.from(data);

        if (!mounted) return;
        setState(() {
          _recentSearches = names;
          isLoading = false;
        });
      } else {
        debugPrint("❌ 사용자 최근 검색 기록 로드 실패: ${response.statusCode}");
        if (!mounted) return;
        setState(() {
          _recentSearches = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ 사용자 최근 검색 기록 로드 중 오류 발생: $e");
      if (!mounted) return;
      setState(() {
        _recentSearches = [];
        isLoading = false;
      });
    }
  }

  // 모든 장소 데이터 가져오기
  Future<List<Map<String, dynamic>>> fetchAllPlaces() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/location/all'));
      if (response.statusCode == 200) {
        debugPrint("✅ 장소 데이터 로드 성공");
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        debugPrint("❌ 장소 데이터 로드 실패: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ 장소 데이터 로드 중 오류 발생: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🔍 가져올 userId: $userId");
    debugPrint('🔍 searchName: $_recentSearches');
    debugPrint(
        '📍 allPlaces names: ${allPlaces?.map((p) => p['name']).toList()}');
    if (isLoading) {
      debugPrint("⏳ 최근 검색 기록 로딩 중...");
      return const Center(child: CircularProgressIndicator());
    }
    if (_recentSearches == null || _recentSearches!.isEmpty) {
      return const Center(child: Text("최근 검색 기록이 없어요 🥲"));
    }

    final searches = _recentSearches!;
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: searches.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          final search = searches[index];
          final searchName = search; // 🔥 name 필드를 꺼낸다!

          final matchedPlace = allPlaces?.firstWhere(
            (place) => place['name'] == search,
            orElse: () => {},
          );
          final imageUrl = matchedPlace?['image'];

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
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                        bottom: Radius.circular(15),
                      ),
                      child: Builder(
                        builder: (context) {
                          final dynamic image = matchedPlace?['image'];
                          String? imageUrl;

                          if (image is List && image.isNotEmpty) {
                            imageUrl = image[0];
                          } else if (image is String) {
                            imageUrl = image;
                          }

                          return imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 140,
                                  width: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 140,
                                    width: 140,
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: Icon(Icons.broken_image)),
                                  ),
                                )
                              : Container(
                                  height: 140,
                                  width: 140,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.place,
                                        size: 40, color: Colors.grey),
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 5, 16.0, 5),
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
                                    place: searchName,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              searchName,
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
  }
}
