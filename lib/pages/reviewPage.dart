import 'dart:convert';
import 'package:final_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'dart:async';
import '../styles/styles.dart';

class ReviewPage extends StatefulWidget {
  final String place;
  const ReviewPage({Key? key, required this.place}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
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
        Uri.parse('http://localhost:8001/api/location/$placeName'), // ✅ 서버 API로 요청
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          //_isPlaceFound = true;
          _matchedPlace = data;
          //_isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // ✅ 장소를 찾을 수 없음
        setState(() {
          //_isLoading = false;
          //_isPlaceFound = false;
        });
      } else {
        throw Exception('Failed to load place data');
      }
    } catch (e) {
      debugPrint("❗ 서버 통신 중 오류 발생: $e");
      setState(() {
        //_isLoading = false;
        //_isPlaceFound = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Review',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: _matchedPlace == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKeywordsSection(_matchedPlace!),
                    const SizedBox(height: 24),
                    //_buildReviewsSection(_matchedPlace!),
                  ],
                ),
              ));
  }

  Widget _buildKeywordsSection(Map<String, dynamic> data) {
    final List<dynamic> keywords = data['keywords'] ?? [];
    final List<dynamic> reviews = data['review'] ?? [];
    keywords.sort((a, b) =>
        (b['sentiment']['total'] ?? 0).compareTo(a['sentiment']['total'] ?? 0));
    if (keywords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('관련 키워드가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            "${reviews.length}개의 리뷰를 분석했어요",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          //IconButton(onPressed: {}, icon: Icon(Icons.smart_button))
        ]),
        const SizedBox(
          height: 10,
        ),
        ...keywords.map((keyword) {
          final String name = keyword['name'].toString();
          final int total = keyword['sentiment']['total'] ?? 0;
          final int pos = keyword['sentiment']['pos'] ?? 0;
          final int neg = keyword['sentiment']['neg'] ?? 0;
          final int neu = keyword['sentiment']['neu'] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Text("$total개의 리뷰를 분석했어요"),
                Text(
                  '$name  $total',
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 4),
                LayoutBuilder(builder: (context, constraints) {
                  double maxBarWidth = constraints.maxWidth;
                  double barFactor = total > 0 ? maxBarWidth / total : 0;
                  return Row(children: [
                    Container(
                      width: pos * barFactor,
                      height: 20,
                      color: AppColors.lightPeriwinkle,
                    ),
                    Container(
                      width: neg * barFactor,
                      height: 20,
                      color: AppColors.mustedBlush,
                    ),
                    Container(
                      width: neu * barFactor,
                      height: 20,
                      color: Colors.grey,
                    ),
                  ]);
                }),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '긍정 $pos개',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '부정 $neg개',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '중립 $neu개',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '전체 $total개',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ]),
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

    debugPrint('✅ Review 불러오기 성공');

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: reviews.map((review) {
            return Container(
              alignment: Alignment.centerLeft,
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
