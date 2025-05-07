import 'package:flutter/material.dart';

class MyTabbedPage extends StatelessWidget {
  const MyTabbedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 탭 수
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '요약'),
                Tab(text: '분석'),
                Tab(text: '리뷰'),
                Tab(text: '정보'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('요약 페이지')),
                Center(child: Text('분석 페이지')),
                Center(child: Text('리뷰 페이지')),
                Center(child: Text('정보 페이지')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}