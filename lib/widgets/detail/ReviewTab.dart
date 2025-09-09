// widgets/detail/ReviewTab.dart
import 'package:final_project/pages/review/writeReviewPage.dart';
import 'package:final_project/services/review_service.dart';
import 'package:final_project/services/sentiment_service.dart';
import 'package:flutter/material.dart';
import 'package:final_project/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReviewsTab extends StatefulWidget {
  final Map<String, dynamic> data;

  const ReviewsTab({Key? key, required this.data}) : super(key: key);

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  String myReview = '';
  String myReviewId = '';
  final prefs = SharedPreferences.getInstance();
  final sentimentService = SentimentService();
  Map<String, dynamic> sentimentResult = {};
  bool _isAnalyzing = false;
  Map<String, dynamic>? _rawSentiment;
  @override
  void initState() {
    super.initState();
    _loadMyReview();
  }

  Future<void> _loadMyReview() async {
    final reviewService = ReviewService();
    final placeId = widget.data['_id'];
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    try {
      final reviewData = await reviewService.getReviewsByLocation(
        placeId,
        token,
        userId,
      );

      setState(() {
        myReview = reviewData['content'] ?? '';
        myReviewId = reviewData['_id'] ?? '';
      });

      debugPrint("📥 내 리뷰: $myReview");

      setState(() {
        _isAnalyzing = true;
      });
      final result = await sentimentService.analyzeSentiment(myReview);
      setState(() {
        _isAnalyzing = false;
      });

      debugPrint("감성 분석 결과: $result");
      setState(() {
        _rawSentiment = result;
      });
      if (result != null && result['sentiments'] != null) {
        setState(() {
          sentimentResult = Map<String, dynamic>.from(result['sentiments']);
        });
        debugPrint("주차 감성: ${result['주차']}");
        debugPrint("화장실 감성: ${result['화장실']}");
        debugPrint("시설관리 감성: ${result['시설관리']}");
        debugPrint("장소 감성: ${result['장소']}");
      }
    } catch (e) {
      debugPrint("❌ 리뷰 불러오기 실패: $e");
      setState(() {
        myReview = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> reviews = widget.data['review'] ?? [];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightWhite,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "내가 쓴 리뷰",
                    style: TextStyles.mediumTextStyle
                        .copyWith(color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  _myReview(),
                  if (sentimentResult.isNotEmpty)
                    _sentimentResult(sentimentResult),
                  const SizedBox(height: 8),
                  if (_isAnalyzing)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightWhite,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: reviews.map((review) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review != null ? review : '리뷰 내용 없음',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myReview() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: () async {
          debugPrint("widget.data['_id']: ${widget.data['_id']}");

          final prefs = await SharedPreferences.getInstance();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WriteReviewPage(
                placeId: widget.data['_id'],
                token: prefs.getString('') ?? '',
              ),
            ),
          );
          if (result != null && result is String) {
            setState(() {
              myReview = result;
            });

            setState(() {
              _isAnalyzing = true;
            });
            final sentiment = await sentimentService.analyzeSentiment(result);
            setState(() {
              _isAnalyzing = false;
              _rawSentiment = sentiment;
            });
            if (sentiment != null && sentiment['sentiments'] != null) {
              setState(() {
                sentimentResult =
                    Map<String, dynamic>.from(sentiment['sentiments']);
              });
            }
          }
        },
        child: (myReview.isEmpty)
            ? const Text(
                "리뷰 작성하기",
                style: TextStyle(color: AppColors.deepGrean),
              )
            : Text(
                myReview,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
      ),
    );
  }
}

Widget _sentimentResult(Map<String, dynamic> sentiments) {
  String translate(String key) {
    switch (key) {
      case 'pos':
        return '긍정';
      case 'neg':
        return '부정';
      case 'none':
      default:
        return '없음';
    }
  }

  Color backgroundColor(String value) {
    switch (value) {
      case 'pos':
        return Colors.green[100]!;
      case 'neg':
        return Colors.red[100]!;
      case 'none':
      default:
        return Colors.grey[300]!;
    }
  }

  return Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "감성 분석 결과",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sentiments.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor(value),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$key: ${translate(value)}",
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
