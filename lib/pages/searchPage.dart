import 'package:flutter/material.dart';
import 'package:final_project/widgets/search_bar.dart' as custom;
import 'package:final_project/widgets/recent_searches.dart';
import 'package:final_project/widgets/search_results.dart';
import 'package:final_project/pages/detailPage.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _allPlaces = []; // 모든 장소 데이터
  List<dynamic> _filteredPlaces = []; // 필터링된 검색 결과
  List<Map<String, dynamic>> _recentSearches = []; // 최근 검색 기록

  @override
  void initState() {
    super.initState();
    _loadPlaces(); // JSON 데이터 로드
  }

  Future<void> _loadPlaces() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/inform.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      _allPlaces = jsonData; // 모든 장소 데이터 저장
    });
  }

  void _filterPlaces(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPlaces = [];
      });
      return;
    }

    final filtered = _allPlaces.where((place) {
      final placeName = place['name'].toString().toLowerCase();
      final keywords = (place['keywords'] as List<dynamic>)
          .map((keyword) => keyword.toString().toLowerCase())
          .toList();

      return placeName.contains(query.toLowerCase()) ||
          keywords.any((keyword) => keyword.contains(query.toLowerCase()));
    }).toList();

    setState(() {
      _filteredPlaces = filtered;
    });
  }

  void _deleteRecentSearch(String placeName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: Text('$placeName 검색 기록을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _recentSearches
                      .removeWhere((search) => search['name'] == placeName);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('검색 기록이 삭제되었습니다.')),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 페이지'),
      ),
      body: Padding(
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
            ),
            const SizedBox(height: 20),

            // 검색 결과
            if (_controller.text.isNotEmpty)
              Flexible(
                child: _filteredPlaces.isNotEmpty
                    ? SearchResults(
                        query: _controller.text,
                        places: _filteredPlaces,
                        onTap: (place) {
                          // DetailPage로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(place: place),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          '검색 결과가 없습니다.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            const SizedBox(height: 16),

            // 최근 검색 기록
            RecentSearches(
              searches: _recentSearches,
              onTap: (placeName) {
                final place = _allPlaces.firstWhere(
                  (p) => p['name'] == placeName,
                  orElse: () => null,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailPage(place: place), // null이 전달될 수 있음
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
