import 'package:flutter/material.dart';
import 'package:final_project/widgets/search_bar.dart' as custom;
import 'package:final_project/widgets/recent_searches.dart';
import 'package:final_project/widgets/search_results.dart';
import 'package:final_project/pages/detailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../widgets/recent_searches.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _userId = "";
  List<dynamic> _allPlaces = []; // 모든 장소 데이터
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _filteredPlaces = []; // 필터링된 검색 결과
  List<String> _recentsearch = []; // 최근 검색 기록

  @override
  void initState() {
    super.initState();
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
      _loadRecentSearch();
      _loadPlaces(); // ✅ 유저 ID가 있을 경우 키워드 불러오기
    }
  }

  // 최근 검색어 가져오기
  Future<void> _loadRecentSearch() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/users/$_userId/recentsearch'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> recentsearch =
            json.decode(response.body); // ✅ JSON을 List로

        debugPrint("최근 검색어 가져오기 성공");

        setState(() {
          _recentsearch = recentsearch.map((item) => item.toString()).toList();
        });
      } else {
        debugPrint("최근 검색어 가져오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❗ 에러 발생: $e");
    }
  }

  // 최근 검색어 추가하기
  Future<void> _addRecentSearch(String query) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/users/$_userId/recentsearch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );
      if (response.statusCode == 201) {
        debugPrint("✅ 검색어 추가 성공");

        setState(() {
          _recentsearch.remove(query); // 중복 검색어 제거
          _recentsearch.insert(0, query); // 최근 검색어 맨 위에 추가
        });
      } else {
        debugPrint("❗ 검색어 추가 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❗ 검색어 추가 중 에러 발생: $e");
    }
  }

  // 최근 검색어 삭제하기
  Future<void> _deleteRecentSearch(String value) async {
    if (_userId.isEmpty) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5001/users/$_userId/recentsearch/$value'),
        headers: {"Content-Type": "application/json"},
      );

      setState(() {
        _recentsearch.remove(value); // 🗑️ 리스트에서 항목 삭제
      });

      if (response.statusCode == 200) {
        debugPrint("✅ 키워드 삭제 성공: $value");
      } else {
        debugPrint("🚨 키워드 삭제 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 키워드 삭제 오류: $e");
    }
  }

  // 최근 검색어 모두 삭제하기
  Future<void> _clearAllRecentSearches() async {
    if (_userId.isEmpty) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5001/users/$_userId/recentsearch'),
        headers: {"Content-Type": "application/json"},
      );

      setState(() {
        _recentsearch.clear(); // 🗑️ 리스트 비우기
      });

      if (response.statusCode == 200) {
        debugPrint("✅ 모든 키워드 삭제 성공");
      } else {
        debugPrint("🚨 모든 키워드 삭제 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 모든 키워드 삭제 오류: $e");
    }
  }

  // 모든 장소 가져오기
  Future<void> _loadPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/location/all'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (mounted) {
          setState(() {
            _allPlaces = data; // Store the response in `_allPlaces`
          });
        }
        debugPrint("✅ 장소 정보 가져오기 성공: ${_allPlaces.length}개 로드됨");
      } else {
        debugPrint("❗ 장소 정보 가져오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❗ 에러 발생: $e");
    }
  }

  void _filterPlaces(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPlaces = [];
      });
      return;
    }

    final filtered = _allPlaces.where((place) {
      final name = place['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    // ✅ 중복 setState() 호출 방지
    if (mounted && !listEquals(_filteredPlaces, filtered)) {
      setState(() {
        _filteredPlaces = filtered;
      });
    }
  }

  Widget _buildRecentSearches() {
    if (_recentsearch.isEmpty) {
      return const Center(
          child: Text('최근 검색 기록이 없습니다.', style: TextStyle(color: Colors.grey)));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "최근 검색 기록",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _clearAllRecentSearches,
                  child: const Text(
                    '모두 삭제',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentsearch.length,
            itemBuilder: (context, index) {
              final placeName = _recentsearch[index];
              return ListTile(
                title: Text(placeName),
                trailing: IconButton(
                  padding: const EdgeInsets.only(left: 20.0),
                  icon: const Icon(Icons.close_outlined, color: Colors.grey),
                  onPressed: () => _deleteRecentSearch(placeName),
                ),
                onTap: () {
                  _addRecentSearch(placeName);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailPage(place: placeName)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(195, 191, 216, 0),
        title: const Text(
          '검색 페이지',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 바
            custom.SearchBar(
                controller: _controller,
                onChanged: _filterPlaces,
                onClear: () {
                  setState(() {
                    _controller.clear();
                    _filteredPlaces = [];
                  });
                },
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    Future.microtask(() {
                      setState(() {
                        _controller.clear();
                        _filteredPlaces = [];
                      });
                    });
                  }
                }),

            // 검색 결과
            if (_controller.text.isNotEmpty)
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                _filteredPlaces.isNotEmpty
                    ? SearchResults(
                        query: _controller.text,
                        places: _filteredPlaces,
                        onTap: (place) {
                          _addRecentSearch(place['name']);

                          setState(() {
                            _controller.clear();
                            _filteredPlaces = [];
                          });
                          // DetailPage로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(place: place['name']),
                            ),
                          );
                        },
                      )
                    : const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Text(
                          '검색 결과가 없습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
              ]),

            const SizedBox(height: 16),
            _buildRecentSearches(),
            // 최근 검색 기록
            // RecentSearches(
            //     searches: _recentsearch,
            //     onTap: _deleteRecentSearch,
            //     onSearches: _addRecentSearch),
          ],
        ),
      ),
    );
  }
}
