import 'dart:io';

import 'package:final_project/widgets/recent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/styles/search.dart';
import 'searchPage.dart';
import 'loginPage.dart'; // 로그아웃 후 로그인 페이지 이동
import 'package:http/http.dart' as http;
import 'package:final_project/widgets/gps.dart';
import './recommendPage.dart';
import 'setKeywordsPage.dart';
import 'package:final_project/widgets/jaccard.dart';
import 'package:final_project/widgets/search_bar.dart' as custom;
import 'package:final_project/widgets/BottomNavi.dart';

final String baseUrl =
Platform.isAndroid ? 'http://10.0.2.2:8001' : 'http://localhost:8001';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String userId = '';
  String userName = '';
  List<String> userPreferences = [];

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 사용자 데이터 로드
  }

  // 사용자 데이터 로드 (SharedPreferences에서 불러오기)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedUser = prefs.getString("userName");
    final String? storedUserId = prefs.getString("userId");

    if (storedUser != null && storedUserId != null) {
      setState(() {
        userName = storedUser;
        userId = storedUserId;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.lighterGreen, // 🔥 여기가 핵심!! 상태바 색 고정
        statusBarIconBrightness:
            Brightness.dark, // 상태바 아이콘 색 (흰색이면 Brightness.light)
      ),
      child: Scaffold(
        backgroundColor: AppColors.lighterGreen, // ✅ Scaffold 배경색 고정
        extendBodyBehindAppBar: false, // ✅ false로 해야 이상한 투명효과 없음
        appBar: AppBar(
          backgroundColor: AppColors.lighterGreen, // ✅ AppBar 배경 고정
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: AppColors.lighterGreen, // 💥 AppBar 밑에도 완전 고정
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.fromLTRB(12.0, 12, 12, 12),
            child: Align(
              alignment: Alignment.centerLeft, // 글자 왼쪽 정렬
              child: Text(
                '여행지 추천 시스템',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.lighterGreen,
                AppColors.lighterGreen,
                AppColors.lightWhite,
                AppColors.lightWhite,
                AppColors.lightWhite,
                AppColors.lightWhite,
                AppColors.lightWhite,
                AppColors.lightWhite,
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //검색바
                        // SearchBar(
                        //   controller: _controller,
                        // ),
                        const SizedBox(height: 20.0),
                        // 사용자 키워드 보여줌
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$userName 님의 주요 여행 취향',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w600),
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
                                        child: Text("설정",
                                            textAlign: TextAlign.start,
                                            style: TextStyles.smallTextStyle
                                                .copyWith(
                                                    color:
                                                        AppColors.deepGrean)))
                                  ],
                                ),
                                const ShowKeywords(),
                              ],
                            )),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "어디로 떠날까요?",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Pretendard',
                                        //letterSpacing: 0.9,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ButtonStyles.bigButtonStyle(
                                        context: context), // ✅ 정상 작동
                                    child: const Text(
                                      "추천 받으러 가기",
                                      style: TextStyles.mediumTextStyle,
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$userName 님을 위한 추천 여행지',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      //letterSpacing: 0.9,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                const RecommendationWidget(),
                              ],
                            )),
                        const SizedBox(height: 20),
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '최근 검색한 여행지',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      //letterSpacing: 0.9,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                RecentSearchWidget()
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavi(),
      ),
    );
  }
}

// 검색바 위젯
class SearchBar extends StatelessWidget {
  const SearchBar({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SearcherStyles.containerPadding,
      decoration: SearcherStyles.containerDecoration,
      height: 40,
      child: TextField(
        textAlign: TextAlign.start,
        cursorColor: SearcherStyles.cursorColor,
        controller: controller,
        //InputDecoration 오류나요 (?)
        decoration: const InputDecoration(
          hintText: '여행지를 검색하세요',
          border: InputBorder.none,
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(),
              ),
            ).then((_) {
              controller.clear();
            });
          }
        },
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
        Uri.parse('$baseUrl/api/users/$userId/keywords'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedKeywords = json.decode(response.body);
        final List<String> selectedKeywords =
            fetchedKeywords.map((k) => k['name'].toString()).toList();

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
            child: Wrap(
              spacing: 10, // ✅ Chip 간의 가로 간격
              runSpacing: 0, // ✅ Chip 간의 세로 간격
              children: [
                ...keywords.take(3).map((keyword) {
                  return Chip(
                    label: Text(
                      keyword,
                      style: AppStyles.keywordChipTextStyle,
                    ),
                    backgroundColor: AppStyles.keywordChipBackgroundColor,
                    shape: AppStyles.keywordChipShape,
                    padding: AppStyles.keywordChipPadding,
                  );
                }).toList(),
                if (keywords.length > 3)
                  const Text(
                    "  ...",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        height: 3.0, color: AppColors.deepGrean), // y축 아래로 내리기
                  )
              ],
            ),
          ),
      ],
    );
  }
}
