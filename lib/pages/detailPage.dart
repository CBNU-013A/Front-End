import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> place;

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
      // Load inform.json
      final String jsonString =
          await rootBundle.loadString('assets/data/inform.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Check if the current place name matches any in the JSON data
      final match = jsonData.firstWhere(
        (place) => place['name'] == widget.place['name'],
        orElse: () => null,
      );

      setState(() {
        _isPlaceFound = match != null;
        _matchedPlace = match;
        _isLoading = false;
      });
    } catch (e) {
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
          title: Text('${widget.place['name']} 정보'),
          backgroundColor: Colors.purple,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isPlaceFound) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.place['name']} 정보'),
          backgroundColor: Colors.purple,
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
        title: Text('${_matchedPlace!['name']} 정보'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션
            _buildImageSection(_matchedPlace!),
            const SizedBox(height: 16),

            // 정보 섹션
            _buildInfoSection(_matchedPlace!),
            const SizedBox(height: 16),

            // 키워드 섹션
            _buildKeywordsSection(_matchedPlace!),
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

  Widget _buildInfoSection(Map<String, dynamic> place) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place['name'] ?? '이름 없음',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '📍 ${place['address'] ?? '주소 정보 없음'}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (place['phone'] != null)
            Text(
              '📞 ${place['phone']}',
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection(Map<String, dynamic> place) {
    final keywords = place['keywords'] as List<dynamic>? ?? [];

    if (keywords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '관련 키워드가 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: keywords.map((keyword) {
          return Chip(
            label: Text(
              keyword.toString(),
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: Colors.blue[100],
          );
        }).toList(),
      ),
    );
  }
}
