// widgets/detail/ReviewTab.dart
import 'package:final_project/pages/review/writeReviewPage.dart';
import 'package:final_project/services/review_service.dart';
import 'package:flutter/material.dart';
import 'package:final_project/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMyReview();
  }

  Future<void> _loadMyReview() async {
    final reviewService = ReviewService();
    final placeId = widget.data['_id'];
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
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
                token: prefs.getString('jwt_token') ?? '',
              ),
            ),
          );
          if (result != null && result is String) {
            setState(() {
              myReview = result;
            });
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
