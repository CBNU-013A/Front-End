// pages/recommend/setTripPage.dart
import 'package:final_project/pages/home/HomePage.dart';
import 'package:final_project/pages/recommend/setWithPage.dart';
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class setTripPage extends StatefulWidget {
  final String userId;
  final String userName;

  const setTripPage({super.key, required this.userId, required this.userName});

  @override
  State<setTripPage> createState() => _setTripPageState();
}

class _setTripPageState extends State<setTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightWhite,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: 3.0),
        backgroundColor: AppColors.lightWhite,
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          TextButton(
            child: const Text(
              "돌아가기",
              style: TextStyle(color: AppColors.lightGray),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            SizedBox(
                height: 147,
                child: Image.asset(
                  'assets/bag.png',
                )),
            const Text('여행을 떠나 볼까요?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const Text('피크가 간단한 질문으로\n 딱 맞는 여행지를 추천해 드릴게요',
                style: TextStyle(
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            Text('${widget.userName} 님의 데이터를 통해 \n 빠르게 추천 받을 수도 있어요 🚀',
                style: const TextStyle(
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                // 다음 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Setwithpage(), // NextPage를 실제 이동할 페이지로 교체하세요.
                  ),
                );
              },
              child: Text("빠른 추천 받기"),
              style: ButtonStyles.bigButtonStyle(context: context),
            ),
            // const SizedBox(height: 5),
            TextButton(
              onPressed: () => {},
              child: Text(
                "돌아가기",
                style: TextStyle(color: AppColors.deepGrean),
              ),
              style: ButtonStyles.bigButtonStyle(context: context).copyWith(
                backgroundColor:
                    MaterialStateProperty.all(AppColors.lightGreen),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(
                  BorderSide(color: AppColors.lightGreen),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
