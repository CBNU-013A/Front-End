import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/homePage.dart'; // 홈 페이지
import 'pages/loginPage.dart';
import 'widgets/splashLogo.dart'; // 로그인 페이지
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget _startScreen = const CircularProgressIndicator(); // 로딩 UI

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 로그인 상태 확인
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token"); // 저장된 JWT 토큰 확인

    if (token != null) {
      setState(() {
        _startScreen = const HomePage(); // 로그인 상태면 홈 화면으로 이동
      });
    } else {
      setState(() {
        _startScreen = const LoginPage(); // 로그인 안 되어 있으면 로그인 페이지로 이동
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ✅ 로컬라이제이션 추가
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 지원
        Locale('en', 'US'), // 영어 지원 (기본)
      ],

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Splash(),
    );
  }
}
