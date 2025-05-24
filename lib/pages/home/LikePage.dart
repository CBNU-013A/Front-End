import 'package:final_project/services/user_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/widgets/BottomNavi.dart';
import 'package:final_project/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';

class Likepage extends StatefulWidget {
  const Likepage({super.key});

  @override
  State<Likepage> createState() => _LikepageState();
}

class _LikepageState extends State<Likepage> {
  final userService = UserService();
  String userId = '';
  String userName = '';

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
      debugPrint("❌ 사용자 정보 없음 (재접속)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightWhite,
      extendBodyBehindAppBar: false,
      appBar: MainAppBar(
        title: '즐겨찾기',
        actions: [],
      ),
      
      bottomNavigationBar: BottomNavi(currentIndex: 1),
    );
  }
}
