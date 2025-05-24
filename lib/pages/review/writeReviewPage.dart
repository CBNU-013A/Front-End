// pages/review/writeReviewPage.dart
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:final_project/services/review_service.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class WriteReviewPage extends StatefulWidget {
  final String? placeId;

  const WriteReviewPage({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final TextEditingController _contentController = TextEditingController();
  String? myReview;

  @override
  void initState() {
    super.initState();
    _loadMyReview();
  }

  Future<void> _loadMyReview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final myUserId =
        prefs.getString('userId'); // fixed key to match saved token
    final reviewService = ReviewService();
    final placeId = widget.placeId ?? '';
    debugPrint("✅ 보내는 userId: $myUserId, placeId: $placeId");
    try {
      final result = await reviewService.fetchReviewsByLocation(
        placeId,
        token,
      );
      final myReviewData = result['myReview'];

      setState(() {
        myReview = myReviewData != null ? myReviewData['content'] ?? '' : '';
        if (myReview != null && myReview!.isNotEmpty) {
          _contentController.text = myReview!;
        }
      });
    } catch (e) {
      debugPrint("❌ 내 리뷰 불러오기 실패: $e");
      setState(() {
        myReview = '';
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final placeId = widget.placeId ?? '';
    final newText = _contentController.text.trim();

    final reviewService = ReviewService();
    bool success = false;

    if ((myReview == null || myReview!.isEmpty) && newText.isNotEmpty) {
      // 새로운 리뷰 작성
      success = await reviewService.createReview(placeId, newText, token);
    } else if ((myReview != null && myReview!.isNotEmpty) && newText.isEmpty) {
      // 리뷰 삭제
      success = await reviewService.deleteReview(placeId, token);
    } else if ((myReview != null && myReview != newText)) {
      // 리뷰 수정
      success = await reviewService.updateReview(placeId, newText, token);
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 처리 완료')),
      );
      Navigator.pop(context, newText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 처리 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightWhite,
        actions: [
          const SizedBox(width: 8.0), // Add spacing before the button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppColors.lightWhite; // Change color when pressed
                  }
                  return AppColors.lightWhite; // Default color
                },
              ),
            ),
            onPressed: _submitReview,
            child: const Text(
              '작성하기',
              style: TextStyle(color: AppColors.deepGrean),
            ),
          ),
          const SizedBox(width: 8.0), // Add spacing after the button
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLength: 100,
          maxLines: 10,
          //expands: true,
          textAlignVertical: TextAlignVertical.top,
          cursorColor: Colors.black,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText:
                '욕설, 비방 등 상대방을 불쾌하게 하는 의견은 남기지 말아주세요. 신고를 당하면 서비스 이용이 제한될 수 있어요.',
            hintMaxLines: 3,
          ),
        ),
      ),
    );
  }
}
