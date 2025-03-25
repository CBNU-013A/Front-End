import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:final_project/styles/styles.dart';
import 'searchPage.dart';
import 'loginPage.dart'; // 로그아웃 후 로그인 페이지 이동
import 'package:http/http.dart' as http;
import 'package:final_project/widgets/gps.dart';
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
    //rfinal List<String>? storedKeywords = prefs.getStringList("userPreferences");

    if (storedUser != null) {
      setState(() {
        userName = storedUser;
        //userPreferences = storedKeywords;
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
            },
            tooltip: "검색",
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //const SizedBox(height: 3),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey
                                  .withOpacity(0.2), // 그림자 색상 (불투명도 조절 가능)
                              spreadRadius: 0.3, // 그림자 확산 정도
                              blurRadius: 0.3, // 그림자 흐림 정도
                              offset: const Offset(
                                  0, 0.1), // x, y축으로 그림자 위치 (0, 3 = 아래쪽 그림자)
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100], // 배경색
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(50),
                                    // border: Border.all(
                                    //     color: Colors.black,
                                    //     width: 0.1), // 테두리 추가
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.person_rounded),
                                    iconSize: 30,
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SetKeywordsPage()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '$userName',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      //letterSpacing: 0.9,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 11,
                            ),
                            const CurrentAddressWidget(),
                            const SizedBox(
                              height: 11,
                            ),
                            const ShowKeywords(),
                          ],
                        )),
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

//홈화면에서 키워드 보여주기
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
          SizedBox(
              // ✅ Chip 높이에 맞게 사이즈 조정
              child: Wrap(
            spacing: 6, // ✅ Chip 간의 가로 간격
            runSpacing: 0, // ✅ Chip 간의 세로 간격
            // ✅ 줄 정렬 방식

            children: keywords.map((keyword) {
              return Chip(
                label: Text(
                  keyword,
                  style: AppStyles.keywordChipTextStyle,
                ),
                backgroundColor: AppStyles.keywordChipBackgroundColor,
                shape: AppStyles.keywordChipShape,
                padding: AppStyles.keywordChipPadding,
                //visualDensity: const VisualDensity(vertical: -1),
              );
            }).toList(),
          )),
      ],
    );
  }
}
