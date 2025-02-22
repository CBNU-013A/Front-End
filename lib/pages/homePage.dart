import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'searchPage.dart';
import 'loginPage.dart'; // 로그아웃 후 로그인 페이지 이동
import 'package:http/http.dart' as http;

import 'setKeywordsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String userName = '';
  List<String> userPreferences = [];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 사용자 데이터 로드
  }

  // 사용자 데이터 로드 (SharedPreferences에서 불러오기)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedUser = prefs.getString("userName");
    final List<String>? storedKeywords = prefs.getStringList("userPreferences");

    if (storedUser != null && storedKeywords != null) {
      setState(() {
        userName = storedUser;
        userPreferences = storedKeywords;
      });
    }
  }

  // 로그아웃 기능 (토큰 삭제 후 로그인 페이지로 이동)
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userName");
    await prefs.remove("userPreferences");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(195, 191, 216, 0),
          title: const Text(
            '여행지 추천 시스템',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout, // 로그아웃 버튼 클릭 시
              tooltip: "로그아웃",
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            }, // 로그아웃 버튼 클릭 시
            tooltip: "검색",
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            //검색 바 & 사용자 취향 설정
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //SizedBox(height: 3),
                    //SearchBar(),

                    const SizedBox(height: 3),
                    SizedBox(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "키워드",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SetKeywordsPage()),
                                        );
                                      },
                                      child: const Text(
                                        "키워드 설정",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start, // ✅ 왼쪽 정렬
                                    children: [
                                      ShowKeywords(),
                                    ]),
                              ],
                            )),
                      ),
                    ),
                    //const ShowKeywords(),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(
                    //   child: PlacePreferencesPage(),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 검색바 위젯
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(CupertinoIcons.search, color: Colors.grey),
            SizedBox(width: 10, height: 35),
            Text(
              '여행지를 검색하세요',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowKeywords extends StatefulWidget {
  const ShowKeywords({super.key});

  @override
  ShowKeywordsState createState() => ShowKeywordsState();
}

class ShowKeywordsState extends State<ShowKeywords> {
  List<String> keywords = []; // ✅ 사용자 키워드 저장 리스트
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // ✅ 1️⃣ SharedPreferences에서 userId 불러오기
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedUserId = prefs.getString("userId");

    if (storedUserId != null && storedUserId.isNotEmpty) {
      setState(() {
        userId = storedUserId;
      });
      _fetchUserKeywords(); // ✅ userId를 가져온 후 키워드 불러오기
    } else {
      debugPrint("🚨 저장된 userId가 없음!");
    }
  }

  // ✅ 2️⃣ 서버에서 사용자 키워드 가져오기
  Future<void> _fetchUserKeywords() async {
    if (userId.isEmpty) {
      debugPrint("🚨 userId가 없음!");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/users/$userId/keywords'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedKeywords = json.decode(response.body);
        final List<String> selectedKeywords =
            fetchedKeywords.map((k) => k["text"].toString()).toList();

        setState(() {
          keywords = selectedKeywords; // ✅ 가져온 키워드를 리스트에 저장
        });

        debugPrint("✅ 사용자 선택 키워드 불러오기 성공: $selectedKeywords");
      } else {
        debugPrint(
            "🚨 사용자 키워드 불러오기 실패: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 사용자 키워드 불러오기 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 키워드가 없을 경우 "선호 키워드가 없습니다." 표시
        if (keywords.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              "선호 키워드가 없습니다.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: Wrap(
              spacing: 5.0,
              runSpacing: 5.0,
              children: keywords
                  .map((keyword) => Chip(
                        label: Text(
                          "#$keyword",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor:
                            const Color.fromRGBO(186, 221, 127, 0.5),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

// // 추천 장소 목록
// class PlacePreferencesPage extends StatefulWidget {
//   const PlacePreferencesPage({super.key});

//   @override
//   PlacePreferencesPageState createState() => PlacePreferencesPageState();
// }

// class PlacePreferencesPageState extends State<PlacePreferencesPage> {
//   List<Place> recommendedPlaces = [];
//   String userName = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadRecommendedPlaces();
//     _loadUserName();
//   }

//   // SharedPreferences에서 로그인된 사용자 이름 불러오기
//   Future<void> _loadUserName() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userName = prefs.getString("userName") ?? "사용자"; // 기본값 "사용자"
//     });
//   }

//   Future<void> _loadRecommendedPlaces() async {
//     try {
//       final String jsonString =
//           await rootBundle.loadString('assets/data/inform.json');
//       final List<dynamic> jsonData = json.decode(jsonString);

//       setState(() {
//         recommendedPlaces =
//             jsonData.map((place) => Place.fromJson(place)).toList();
//       });
//     } catch (e) {
//       debugPrint('Error loading places: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return recommendedPlaces.isEmpty
//         ? const Center(
//             child: Text('추천할 관광지가 없습니다.', style: TextStyle(color: Colors.grey)))
//         : Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Text(
//                   "$userName 님을 위한 추천 관광지",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 420.0,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: recommendedPlaces.length,
//                   itemBuilder: (context, index) {
//                     return SizedBox(
//                       width: 340,
//                       child: PlaceCard(place: recommendedPlaces[index]),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//   }
// }

// // 장소 카드 위젯
// class PlaceCard extends StatelessWidget {
//   final Place place;
//   const PlaceCard({super.key, required this.place});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: const Color.fromARGB(255, 249, 243, 232),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildImageSection(),
//           _buildContentSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageSection() {
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(
//         top: Radius.circular(10.0),
//       ),
//       child: SizedBox(
//         width: double.infinity,
//         height: 200,
//         child: Image.asset(
//           place.imageUrl,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return const Center(
//               child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildContentSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             place.name,
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             place.address,
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 5.0,
//             children: place.keywords.map((keyword) {
//               return Chip(
//                 label: Text(keyword,
//                     style: const TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.bold)),
//                 backgroundColor: const Color.fromRGBO(170, 186, 154, 1),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }
