import 'dart:convert';
import './searchPage.dart';
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
          'Detail',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(_matchedPlace!),
            _buildKeywordsSection(_matchedPlace!),
            _buildInfoSection(_matchedPlace!),
            _buildMapSection(_matchedPlace!),
            _buildReviewsSection(_matchedPlace!),
          ],
        ),
      ),
    );
    // body: Stack(children: [
    //   // 배경 이미지

    //   Positioned.fromRect(
    //     rect: const Rect.fromLTWH(12.0, 60.0, 380, 500),
    //     child: Container(
    //       //padding: const EdgeInsets.all(16.0),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10),
    //         color: AppColors.mustedBlush.withOpacity(0.2),
    //         image: DecorationImage(
    //             image: _matchedPlace!['image'] != null
    //                 ? NetworkImage(_matchedPlace!['image']) as ImageProvider
    //                 : AssetImage('assets/images/default_image.jpg')
    //                     as ImageProvider, // 배경 이미지 경로
    //             fit: BoxFit.cover,
    //             opacity: 0.9 // 화면에 꽉 차게 설정
    //             ),
    //       ),
    //     ),
    //   ),

    // ✅ SafeArea를 사용하여 버튼이 잘 보이도록 조정
    //   SafeArea(
    // child: Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     AppBar(
    //       backgroundColor: Colors.transparent,
    //       // title: Text('${_matchedPlace!['name']}',
    //       //     style: const TextStyle(
    //       //       fontSize: 20,
    //       //       fontWeight: FontWeight.bold,
    //       //       color: Colors.white,
    //       //       shadows: [
    //       //         Shadow(
    //       //           color: AppColors.marineBlue,
    //       //           offset: Offset(1, 2),
    //       //           blurRadius: 2,
    //       //         )
    //       //       ],
    //       //     )),
    //     ),

    // ✅ SafeArea 내부에 포함된 스크롤 뷰
  }

  Widget _buildImageSection(Map<String, dynamic> place) {
    List<String> imageUrls = List<String>.from(place['image'] ?? []);
    debugPrint("Image URLs: $imageUrls");
    // 🔹 이미지가 없으면 기본 이미지 추가 (예방)
    if (imageUrls.isEmpty) {
      imageUrls.add('https://example.com/default_image.jpg');
    }
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
            height: 200.0,
            //width: double.infinity,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        height: 200.0,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            alignment: Alignment.center,
                            height: 200,
                            width: 350,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                })));
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['name'] ?? '이름 없음',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞춤
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 20, color: Color(0xFF4738D7)),
              const SizedBox(width: 4), // 아이콘과 텍스트 간격 조정
              Text(
                '${data['address'] ?? '주소 정보 없음'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (data['tell'] != null)
            Row(
              mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞춤
              children: [
                const Icon(Icons.phone, size: 20, color: Color(0xFF4738D7)),
                const SizedBox(width: 4), // 아이콘과 텍스트 간격 조정
                Text(
                  '${data['tell'] ?? '주소 정보 없음'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMapSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: keywords.map((keyword) {
          return Padding(
            padding: EdgeInsets.only(right: 5),
            child: Chip(
              labelPadding: const EdgeInsets.only(left: 8, right: 8),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.lightTaube),
              ),
              backgroundColor: AppColors.lightTaube,

              //padding: AppStyles.keywordChipPadding.copyWith(left: 8, right: 8),
              label: Text("$keyword" ?? "알 수 없음",
                  style: AppStyles.keywordChipTextStyle
                      .copyWith(fontSize: 14)), // ✅ `text` 반환
            ),
          );
        }).toList()),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: reviews.map((review) {
            return Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review ?? '알 수 없음',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
