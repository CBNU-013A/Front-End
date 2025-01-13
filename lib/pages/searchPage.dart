import 'package:flutter/material.dart';
import 'package:final_project/widgets/search_bar.dart' as custom;
import 'package:final_project/widgets/recent_searches.dart';
import 'package:final_project/widgets/search_results.dart';
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

  void _navigateToDetail(Map<String, dynamic> place) {
    // 상세 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(place: place),
      ),
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
            SizedBox(height: 20),
            // 검색 결과
            Flexible(
              child: _controller.text.isNotEmpty && _filteredPlaces.isNotEmpty
                  ? SizedBox(
                      child: Expanded(
                        child: SearchResults(
                          query: _controller.text,
                          places: _filteredPlaces,
                          onTap: _navigateToDetail,
                        ),
                      ),
                    )
                  : const SizedBox(), // 검색 텍스트가 없거나 결과가 없으면 빈 위젯 반환
            ),

            // 최근 검색 기록
            RecentSearches(
              onTap: (placeName) {
                final place = _allPlaces.firstWhere(
                  (p) => p['name'] == placeName,
                  orElse: () => null,
                );
                if (place != null) _navigateToDetail(place);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> place;

  const DetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${place['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Address: ${place['address'] ?? 'No address available'}'),
            const SizedBox(height: 8),
            Text('Keywords: ${place['keywords'].join(', ')}'),
          ],
        ),
      ),
    );
  }
}
