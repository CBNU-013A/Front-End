// pages/recommend/setKeywordsPage.dart
import 'dart:io';

import 'package:final_project/pages/home/homePage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:final_project/styles/styles.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';
    
class SetKeywordsPage extends StatefulWidget {
  const SetKeywordsPage({super.key});

  @override
  State<SetKeywordsPage> createState() => _SetKeywordsPageState();
}

class _SetKeywordsPageState extends State<SetKeywordsPage> {
  //전체 키워드 목록 id, text 포함
  List<Map<String, dynamic>> _keywords = [];
  //사용자가 선택한 키워드 _id 리스트
  List<String> _selectedKeywords = [];
  //로그인 사용자 Id
  String _userId = "";

  @override
  void initState() {
    super.initState();
    //_fetchKeywords();
    _loadUserId(); //userid 로드 후 -> 그 다음에 키워드 불러오기
  }

  // 1. 로그인된 사용자 ID 불러오기
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("userId") ?? "";
      debugPrint("📌 저장된 userId: $_userId");
    });
    if (_userId.isEmpty) {
      debugPrint("🚨 저장된 userId가 없음!");
    } else {
      _loadKeywords(); //모든 키워드 불러오기
      _fetchUserKeywords(); //사용자 선택 키워드 불러오기
    }
  }

  // 2. 모든 키워드 가져오기
  Future<void> _loadKeywords() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/keywords/all'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedKeywords =
            json.decode(response.body); // ✅ JSON을 List로 변환

        debugPrint("$fetchedKeywords");
        _keywords = fetchedKeywords
            .map((json) => {
                  "_id": json["_id"],
                  "name": json["name"],
                  // ✅ 키워드 내용 저장
                })
            .toList();
      } else {
        debugPrint(
            "🚨 _loadKeywords() 키워드 불러오기 실패: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("👿 키워드 목록 가져오기 오류: $e");
    }
  }

  // 3. 사용자 키워드 불러오기
  Future<void> _fetchUserKeywords() async {
    if (_userId.isEmpty) {
      debugPrint("🚨 userId가 없음!");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$_userId/keywords'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedKeywords = json.decode(response.body);
        debugPrint("✅ 사용자 키워드 불러오기 성공: $fetchedKeywords");

        final List<String> selectedIds =
            fetchedKeywords.map((k) => k["_id"].toString()).toList();
        debugPrint("✅ 사용자 선택 키워드 불러오기 성공: $selectedIds");

        setState(() {
          _selectedKeywords = selectedIds;
          _sortKeywords(); // ✅ 선택된 키워드를 상단으로 정렬
        });
      } else {
        debugPrint(
            "🚨 사용자 키워드 불러오기 실패: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 사용자 키워드 불러오기 오류: $e");
    }
  }

  // 4. 사용자 키워드 추가
  Future<void> _addKeyword(String keywordId) async {
    if (_userId.isEmpty) {
      debugPrint("🚨 userId가 없음!");
      return;
    }

    if (keywordId.isEmpty) {
      debugPrint("🚨 keywordId가 비어 있음!");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/$_userId/keywords'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "keywordId": keywordId,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint("✅ 키워드 추가 성공: $keywordId");
        await _fetchUserKeywords();
      } else if (response.statusCode == 409) {
        debugPrint("⚠️ 이미 존재하는 키워드: $keywordId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ " 이미 추가된 키워드입니다.')),
        );
      } else {
        debugPrint("🚨 키워드 추가 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 키워드 추가 오류: $e");
    }
  }

  // 5. 사용자 키워드 삭제
  Future<void> _deleteKeyword(String keywordId) async {
    if (_userId.isEmpty) return;
    if (keywordId.isEmpty) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$_userId/keywords/$keywordId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ 키워드 삭제 성공: $keywordId");
      } else {
        debugPrint("🚨 키워드 삭제 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 키워드 삭제 오류: $e");
    }
  }

  // 6. 키워드 초기화 (user keyword)
  Future<void> _resetKeyword() async {
    if (_userId.isEmpty) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$_userId/keywords'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ 키워드 초기화 성공");

        // ✅ 선택된 키워드 초기화 및 UI 업데이트
        setState(() {
          _selectedKeywords.clear();
        });

        // ✅ 사용자에게 알림 표시 (닫기 버튼 포함)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarStyles.info("키워드가 초기화되었습니다."),
        );
      } else {
        debugPrint("🚨 키워드 초기화 실패: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🚨 키워드 초기화 실패: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint("🚨 키워드 초기화 오류: $e");
    }
  }

  // 7. 키워드 선택 토글
  void _toggleKeyword(String keywordId) {
    //final isSelected = _selectedKeywords.contains(keywordId);

    setState(() {
      if (_selectedKeywords.contains(keywordId)) {
        //이미 선택된 경우 -> 해제
        _selectedKeywords.remove(keywordId);
        _deleteKeyword(keywordId); //
      } else {
        //선택되지 않은 경우 -> 선택
        _selectedKeywords.add(keywordId);
        _addKeyword(keywordId);
      }
    });

    _sortKeywords();
  }

  // 8. 선택된 키워드 상단 정렬
  void _sortKeywords() {
    setState(() {
      _keywords.sort((a, b) {
        int aSelected = _selectedKeywords.contains(a["_id"]) ? 1 : 0;
        int bSelected = _selectedKeywords.contains(b["_id"]) ? 1 : 0;
        return bSelected - aSelected; // ✅ 선택된 키워드를 상단으로 정렬
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: null,
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: AppColors.lighterGreen,
          title: const Text(
            "키워드 설정",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ),
      ),
      body: Container(
        decoration: BoxStyles.backgroundBox(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "관심 있는 키워드를 선택해주세요!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8.0, // ✅ 태그 간 가로 간격
                      runSpacing: 3.0, // ✅ 줄 간 세로 간격
                      children: _keywords.map((keyword) {
                        final keywordId = keyword["_id"] ?? "";
                        final text = keyword["name"] ?? "";
                        //debugPrint(keyword["text"]);
                        final bool isSelected =
                            _selectedKeywords.contains(keywordId);
                        return TextButton(
                          onPressed: () {
                            // 키워드 토글
                            if (keywordId.isNotEmpty) {
                              _toggleKeyword(keywordId);
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppColors.lightGreen // ✅ 선택된 경우 (파란색)
                                : Colors.white, // ✅ 기본 배경색 (연한 회색)
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 1),
                            side: const BorderSide(
                                color: AppColors.lightGreen, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              // ✅ 둥근 테두리
                            ),
                          ),
                          child: Text(text,
                              style: AppStyles.keywordChipTextStyle.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.deepGrean // ✅ 선택된 경우 (흰색)
                                    : AppColors.deepGrean, // ✅ 기본 글자색 (검정색)
                              )),
                        );
                      }).toList(),
                    ),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _resetKeyword();
                        },
                        child: const Text(
                          "초기화",
                          style: TextStyle(
                            color: AppColors.deepGrean,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
