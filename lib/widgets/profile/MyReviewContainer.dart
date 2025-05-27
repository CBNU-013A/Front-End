import 'package:final_project/services/review_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:flutter/material.dart';

class MyReviewContainer extends StatefulWidget {
  const MyReviewContainer({super.key});

  @override
  State<MyReviewContainer> createState() => _MyReviewContainerState();
}

class _MyReviewContainerState extends State<MyReviewContainer> {
  final userService = UserService();
  final reviewService = ReviewService();
  String userId = '';
  String userName = '';
  List<dynamic> reviews = [];
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final userData = await userService.loadUserData();

    if (userData.isNotEmpty) {
      setState(() {
        userId = userData['userId'] ?? '';
        userName = userData['userName'] ?? '';
      });
    } else {
      debugPrint("❌ 사용자 정보 없음");
    }
  }

  // void loadReviews() async {
  //   final reviews = await reviewService;
  //   ;
  // }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
