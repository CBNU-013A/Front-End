// widgets/home/ShowKeywords.dart
//홈화면에서 키워드 보여주기
import 'package:final_project/services/user_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
