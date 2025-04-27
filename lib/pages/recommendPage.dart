import 'package:flutter/material.dart';

class RecommendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 페이지'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '추천 콘텐츠를 여기에 표시합니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
