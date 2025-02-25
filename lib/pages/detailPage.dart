import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../styles/styles.dart';

class DetailPage extends StatefulWidget {
  final String place;

  const DetailPage({super.key, required this.place});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = true;
  bool _isPlaceFound = false;
  Map<String, dynamic>? _matchedPlace;

  @override
  void initState() {
    super.initState();
    _loadPlaceData();
  }

  Future<void> _loadPlaceData() async {
    try {
      final String placeName = Uri.encodeComponent(widget.place);
      final response = await http.get(
        Uri.parse('http://localhost:5001/location/$placeName'), // ✅ 서버 API로 요청
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _isPlaceFound = true;
          _matchedPlace = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // ✅ 장소를 찾을 수 없음
        setState(() {
          _isLoading = false;
          _isPlaceFound = false;
        });
      } else {
        throw Exception('Failed to load place data');
      }
    } catch (e) {
      debugPrint("❗ 서버 통신 중 오류 발생: $e");
      setState(() {
        _isLoading = false;
        _isPlaceFound = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.place} ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isPlaceFound) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.place}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text(
            '해당 장소에 대한 데이터를 찾을 수 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_matchedPlace!['name']}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(_matchedPlace!),
            _buildInfoSection(_matchedPlace!),
            _buildMapSection(_matchedPlace!),
            _buildKeywordsSection(_matchedPlace!),
            _buildReviewsSection(_matchedPlace!),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Map<String, dynamic> place) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        place['image_url'] ?? 'assets/images/default_image.jpg',
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            alignment: Alignment.center,
            height: 200,
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              size: 60,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['name'] ?? '이름 없음',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('${data['address'] ?? '주소 정보 없음'}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(
            height: 5,
          ),
          if (data['tell'] != null)
            Text('${data['tell']}', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMapSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('여기에 지도 api\n'
          '위도: ${data['location']['latitude']}, 경도: ${data['location']['longitude']}'),
    );
  }

  Widget _buildKeywordsSection(Map<String, dynamic> data) {
    final List<dynamic> keywords = data['keywords'] ?? [];
    if (keywords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('관련 키워드가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    debugPrint('Keywords: ${data['keywords']}');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: keywords.map((keyword) {
          return Chip(
            backgroundColor: AppStyles.keywordChipBackgroundColor,
            padding: AppStyles.keywordChipPadding,
            label: Text("#$keyword" ?? '알 수 없음',
                style: AppStyles.keywordChipTextStyle), // ✅ `text` 반환
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsSection(Map<String, dynamic> data) {
    final List<dynamic> reviews = data['review'] ?? [];
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('관련 리뷰가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    debugPrint('Reviews: ${data['review']}');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: reviews.map((review) {
          return Row(
            children: [
              Text(
                "$review" ?? '알 수 없음', // 🔥 문제 발생 부분
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
