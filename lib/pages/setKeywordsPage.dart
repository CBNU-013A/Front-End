import 'package:final_project/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:final_project/styles/styles.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetKeywordsPage extends StatefulWidget {
  const SetKeywordsPage({super.key});

  @override
  State<SetKeywordsPage> createState() => _SetKeywordsPageState();
}

class _SetKeywordsPageState extends State<SetKeywordsPage> {
  //final TextEditingController _keywordController = TextEditingController();
  List<Map<String, dynamic>> _keywords = [];
  List<String> _selectedKeywords = [];
  String _userId = "";

  @override
  void initState() {
    super.initState();
    //_fetchKeywords();
    _loadUserId();
  }

  // 토글 키워드
  void _toggleKeyword(String keywordId) {
    bool isSelected = _selectedKeywords.contains(keywordId);

    setState(() {
      if (isSelected) {
        _selectedKeywords.remove(keywordId);
        _deleteKeyword(keywordId); // ✅ 선택 해제 시 DB에서 삭제
      } else {
        _selectedKeywords.add(keywordId);
        _addKeyword(keywordId); // ✅ 선택 추가 시 DB에 저장
      }
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _sortKeywords(); // ✅ 선택된 키워드를 상단으로 정렬
      });
    });
  }

  void _sortKeywords() {
    setState(() {
      _keywords.sort((a, b) {
        int aSelected = _selectedKeywords.contains(a["_id"]) ? 1 : 0;
        int bSelected = _selectedKeywords.contains(b["_id"]) ? 1 : 0;
        return bSelected - aSelected; // ✅ 선택된 키워드를 상단으로 정렬
      });
    });
  }

  // 🔹 로그인된 사용자 ID 불러오기
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("userId") ?? "";
      debugPrint("📌 저장된 userId: $_userId");
    });
    if (_userId.isEmpty) {
      debugPrint("🚨 저장된 userId가 없음!");
    } else {
      _loadKeywords();
      _fetchUserKeywords(); // ✅ 유저 ID가 있을 경우 키워드 불러오기
    }
  }

  // All Keywords 가져오기
  Future<void> _loadKeywords() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/keywords/all'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedKeywords =
            json.decode(response.body); // ✅ JSON을 List로 변환

        debugPrint("✅ 모든 키워드 가져오기 성공");

        setState(() {
          _keywords = fetchedKeywords
              .map((keyword) => {
                    "_id": keyword["_id"] ?? "", // ✅ 키워드 ID 저장
                    "text": keyword["text"] ?? "알 수 없음" // ✅ 키워드 내용 저장
                  })
              .toList();
        });
      } else {
        debugPrint(
            "🚨 _loadKeywords() 키워드 불러오기 실패: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("👿 키워드 목록 가져오기 오류: $e");
    }
  }

  // // 🔹 DB에서 로그인된 사용자의 키워드 목록 가져오기
  // Future<void> _fetchKeywords() async {
  //   if (_userId.isEmpty) return; // 로그인된 유저가 없으면 실행하지 않음

  //   try{
  //     final response = await http.get(
  //       Uri.parse('http://localhost:5001/users/$_userId/keywords'),
  //     );

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _keywords = List<String>.from(json.decode(response.body));
  //       });
  //       debugPrint("✅ 키워드 불러오기 성공: $_keywords");
  //     } else {
  //       debugPrint("🚨 키워드 불러오기 실패: ${response.statusCode} ${response.body}");
  //     }
  //   } catch (e) {
  //     debugPrint("🚨 키워드 목록 가져오기 오류: $e");
  //   }
  // }

  // 키워드 추가 (user keyword)
  Future<void> _addKeyword(String keywordId) async {
    if (_userId.isEmpty) {
      debugPrint("🚨 userId가 없음!");
      return;
    }

    if (keywordId.isEmpty) {
      debugPrint("🚨 keywordId가 비어 있음!");
      return;
    }

    final requestBody = jsonEncode({
      "keywordId": keywordId,
    });

    debugPrint("📌 추가 요청 userId: $_userId, keywordId: $keywordId");
    debugPrint("📌 요청 바디: $requestBody");

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/users/$_userId/keywords'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "keywordId": keywordId,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint("✅ 키워드 추가 성공: $keywordId");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('키워드 "$keywordId"가 추가되었습니다.'),
        //   ),

        _fetchUserKeywords();
      } else if (response.statusCode == 409) {
        debugPrint("⚠️ 이미 존재하는 키워드: $keywordId");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ " 이미 추가된 키워드입니다.')),
        );
      } else {
        debugPrint("🚨 키워드 추가 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 키워드 추가 오류: $e");
    }
  }

  Future<void> _fetchUserKeywords() async {
    if (_userId.isEmpty) {
      debugPrint("🚨 userId가 없음!");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/users/$_userId/keywords'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedKeywords = json.decode(response.body);
        final List<dynamic> selectedKeywords =
            fetchedKeywords.map((k) => k["text"].toString()).toList();
        debugPrint("✅ 사용자 선택 키워드 불러오기 성공: $selectedKeywords");

        setState(() {
          _selectedKeywords =
              fetchedKeywords.map((k) => k["_id"].toString()).toList();
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

  // 키워드 삭제 (user keyword)
  Future<void> _deleteKeyword(String keywordId) async {
    if (_userId.isEmpty) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5001/users/$_userId/keywords/$keywordId'),
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

  //키워드 초기화 (user keyword)
  Future<void> _resetKeyword() async {
    if (_userId.isEmpty) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5001/users/$_userId/keywords'),
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

  // // 🔹 키워드 삭제 (DB에서 제거)
  // Future<void> _removeKeyword(int index) async {
  //   if (_userId.isEmpty) return; // 로그인된 유저가 없으면 실행하지 않음

  //   String keywordId = _keywords[index]['_id'];

  //   try {
  //     final response = await http.delete(
  //       Uri.parse('http://localhost:5001/keywords/$keywordId?userId=$_userId'),
  //       headers: {"Content-Type": "application/json"},
  //     );

  //     if (response.statusCode == 200) {
  //       _fetchKeywords(); // ✅ 키워드 삭제 후 목록 다시 불러오기
  //     } else {
  //       debugPrint("🚨 키워드 삭제 실패: ${response.body}");
  //     }
  //   } catch (e) {
  //     debugPrint("🚨 키워드 삭제 오류: $e");
  //   }
  // }

  // Future<void> saveUserId(String userId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("userId", userId);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: const Color.fromRGBO(195, 191, 216, 0),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(
                //   height: 50,
                //   child: TextField(
                //     cursorColor: Colors.grey,
                //     controller: _keywordController,
                //     decoration: InputDecoration(
                //       labelText: "키워드 입력",
                //       labelStyle: const TextStyle(color: Colors.black),
                //       border: OutlineInputBorder(),
                //       focusedBorder: const OutlineInputBorder(
                //         borderSide: BorderSide(
                //           color: Color.fromARGB(255, 149, 189, 108),
                //         ),
                //       ),
                //       enabledBorder: const OutlineInputBorder(
                //         borderSide: BorderSide(
                //           color: Color.fromARGB(255, 149, 189, 108),
                //         ),
                //       ),
                //       // suffixIcon: IconButton(
                //       //   icon: const Icon(Icons.add),
                //       //   onPressed: _addKeyword,
                //       // ),
                //     ),
                //     //onSubmitted: (value) => _addKeyword(),
                //   ),
                // ),

                const Text(
                  "관심 있는 키워드를 선택해주세요!",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: Wrap(
                    spacing: 8.0, // ✅ 태그 간 가로 간격
                    runSpacing: 3.0, // ✅ 줄 간 세로 간격
                    children: _keywords.map((keyword) {
                      return TextButton(
                        onPressed: () {
                          String keywordId =
                              keyword["_id"] ?? ""; // ✅ null일 경우 빈 문자열로 처리
                          if (keywordId.isNotEmpty) {
                            _toggleKeyword(keywordId);
                          } else {
                            debugPrint("🚨 키워드 ID가 null이거나 빈 문자열입니다.");
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              _selectedKeywords.contains(keyword["_id"] ?? "")
                                  ? const Color(0xFFbf99ff) // ✅ 선택된 경우 (파란색)
                                  : Colors.transparent, // ✅ 기본 배경색 (연한 회색)
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          side: const BorderSide(
                              color: Color.fromARGB(255, 215, 192, 255),
                              width: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            // ✅ 둥근 테두리
                          ),
                        ),
                        child: Text("${keyword["text"]}",
                            style: AppStyles.keywordChipTextStyle.copyWith(
                              fontSize: 15,
                              color: _selectedKeywords
                                      .contains(keyword["_id"] ?? "")
                                  ? Colors.white // ✅ 선택된 경우 (흰색)
                                  : const Color(0xFFbf99ff), // ✅ 기본 글자색 (검정색)
                            )),
                      );
                    }).toList(),
                    // IconButton(
                    //   icon: const Icon(Icons.delete_outline,
                    //       color: Colors.grey),
                    //   onPressed: () => _removeKeyword(index),
                    // ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _resetKeyword();
                      },
                      child: const Text(
                        "초기화",
                      ),
                    ),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
