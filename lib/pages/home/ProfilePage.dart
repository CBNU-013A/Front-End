import 'package:final_project/styles/styles.dart';
import 'package:final_project/widgets/BottomNavi.dart';
import 'package:final_project/widgets/main_app_bar.dart';
import 'package:final_project/widgets/profile/MyProfileContainer.dart';
import 'package:flutter/material.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  Widget _section(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...items.map(
            (text) => Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(text),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 페이지 이동
                  },
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightWhite,
      extendBodyBehindAppBar: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),

            // 👤 프로필 영역
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            const Text('조은지',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('@joeunji', style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),

            //내 정보 컨테이너

            const SizedBox(height: 10),
            const MyProfileContainer(infoTitle: "내가 쓴 리뷰"),
            const SizedBox(height: 10),
            const MyProfileContainer(infoTitle: "즐겨찾기 항목"),
            const SizedBox(height: 10),
            const MyProfileContainer(infoTitle: "나의 지역"),
            const SizedBox(height: 10),
            const MyProfileContainer(infoTitle: "내 정보"),
            // 🧾 버튼들

            const SizedBox(height: 30),

            // // 📌 섹션 리스트
            // _section('활동', ['리워드 사용 내역', '나의 활동', '내 정보']),
            // _section('고객센터', ['자주 묻는 질문', '공지사항']),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavi(currentIndex: 3),
    );
  }
}
