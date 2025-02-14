import 'package:final_project/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetKeywordsPage extends StatefulWidget {
  const SetKeywordsPage({super.key});

  @override
  State<SetKeywordsPage> createState() => _SetKeywordsPageState();
}

class _SetKeywordsPageState extends State<SetKeywordsPage> {
  final TextEditingController _keywordController = TextEditingController();
  List<Map<String, dynamic>> _keywords = [];
  String _userId = "";

  @override
  void initState() {
    super.initState();
    //_fetchKeywords();
    _loadUserId();
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
      _fetchKeywords(); // ✅ 유저 ID가 있을 경우 키워드 불러오기
    }
  }

  // 🔹 DB에서 로그인된 사용자의 키워드 목록 가져오기
  Future<void> _fetchKeywords() async {
    if (_userId.isEmpty) return; // 로그인된 유저가 없으면 실행하지 않음

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/users/$_userId/keywords'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _keywords =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        debugPrint("✅ 키워드 불러오기 성공: $_keywords");
      } else {
        debugPrint("🚨 키워드 불러오기 실패: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 키워드 목록 가져오기 오류: $e");
    }
  }

  // 🔹 키워드 추가 (DB에 저장)
  Future<void> _addKeyword() async {
    if (_keywordController.text.isEmpty || _userId.isEmpty) {
      debugPrint("🚨 userId가 없음 또는 키워드가 비어 있음");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/keywords'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "keyword": _keywordController.text,
          "userId": _userId,
        }),
      );

      if (response.statusCode == 201) {
        _fetchKeywords(); // ✅ 키워드 추가 후 목록 다시 불러오기
        _keywordController.clear();
      } else {
        debugPrint("🚨 키워드 추가 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 키워드 추가 오류: $e");
    }
  }

  // 🔹 키워드 삭제 (DB에서 제거)
  Future<void> _removeKeyword(int index) async {
    if (_userId.isEmpty) return; // 로그인된 유저가 없으면 실행하지 않음

    String keywordId = _keywords[index]['_id'];

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5001/keywords/$keywordId?userId=$_userId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        _fetchKeywords(); // ✅ 키워드 삭제 후 목록 다시 불러오기
      } else {
        debugPrint("🚨 키워드 삭제 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 키워드 삭제 오류: $e");
    }
  }

  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", userId);
  }

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
            children: [
              TextField(
                controller: _keywordController,
                decoration: InputDecoration(
                  labelText: "키워드 입력",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addKeyword,
                  ),
                ),
                onSubmitted: (value) => _addKeyword(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _keywords.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(_keywords[index]['keyword']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeKeyword(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
