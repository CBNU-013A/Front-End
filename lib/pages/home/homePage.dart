// pages/home/homePage.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:final_project/styles/styles.dart';
import 'package:final_project/styles/search.dart';
import 'package:final_project/styles/text_styles.dart';
import 'package:final_project/widgets/main_app_bar.dart';
import 'package:final_project/widgets/recent.dart';
import 'package:final_project/widgets/BottomNavi.dart';
import 'package:final_project/widgets/jaccard.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/pages/home/searchPage.dart';
import 'package:final_project/pages/auth/loginPage.dart';
import 'package:final_project/pages/recommend/setKeywordsPage.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    debugPrint("_loadUserData 호출됨");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      debugPrint("SharedPreferences에서 토큰을 찾을 수 없음");
      return;
    }

    setState(() {
      userId = prefs.getString('userId')!;
      userName = prefs.getString('userName')!;
      // userName = userData['name'] ?? '';

      debugPrint("_loadUserData(): userId=$userId, userName=$userName");
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');
    final saveId = prefs.getBool('saveId');

    await prefs.clear();

    if (saveId != null && saveId) {
      await prefs.setBool('saveId', saveId);
      await prefs.setString('savedEmail', savedEmail!);
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lighterGreen,
      extendBodyBehindAppBar: false,
      appBar: MainAppBar(
        title: '여행지 추천 시스템',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              await _logout();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxStyles.backgroundBox(),
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
                      // ... 님의 주요 여행 취향
                      UserPreferencesSection(
                        userName: userName,
                        onEdit: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SetKeywordsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // 어디로 떠날까요?
                      ExplorePromptSection(
                        onPressed: () {
                          // 추천 받으러 가기
                        },
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
                                style: AppTextStyles.sectionTitle,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '최근 검색한 여행지',
                                style: AppTextStyles.sectionTitle,
                                textAlign: TextAlign.center,
                              ),
                              const RecentSearchWidget()
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

  Future<void> _fetchUserKeywords() async {
    if (userId.isEmpty) {
      debugPrint("🚨 userId가 없음!");
      return;
    }

    try {
      final userService = UserService();
      final selectedKeywords = await userService.fetchUserKeywords(userId);
      if (!mounted) return;
      setState(() {
        keywords = selectedKeywords;
      });
      debugPrint("✅ 사용자 선택 키워드 불러오기 성공: $selectedKeywords");
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

// 사용자 취향 섹션 위젯 추출
class UserPreferencesSection extends StatelessWidget {
  final String userName;
  final VoidCallback onEdit;

  const UserPreferencesSection({
    super.key,
    required this.userName,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '$userName 님의 주요 여행 취향',
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: onEdit,
                child: Text(
                  "설정",
                  textAlign: TextAlign.start,
                  style: TextStyles.smallTextStyle
                      .copyWith(color: AppColors.deepGrean),
                ),
              ),
            ],
          ),
          const ShowKeywords(),
        ],
      ),
    );
  }
}

// 어디로 떠날까요? 프롬프트 섹션 위젯 추출
class ExplorePromptSection extends StatelessWidget {
  final VoidCallback onPressed;

  const ExplorePromptSection({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "어디로 떠날까요?",
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: onPressed,
              style: ButtonStyles.bigButtonStyle(context: context),
              child: Text(
                "추천 받으러 가기",
                style: TextStyles.mediumTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
