import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/homePage.dart'; // 홈 페이지
import 'pages/loginPage.dart';
import 'widgets/splashLogo.dart'; // 로그인 페이지
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
//import 'package:kakao_map_sdk/kakao_map.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository.initialize(appKey: 'c4e1eb2e4df9471dd1f08410194cfd13');

  KakaoSdk.init(
    nativeAppKey: '2a9e7d21868ff0932e17ad3708dcbe9b',
    javaScriptAppKey: 'c4e1eb2e4df9471dd1f08410194cfd13',
  );

  // Kakao SDK 초기화 여부 확인
  debugPrint("✅ kakaoSdk 초기화 ");

  runApp(const MyApp());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(); // ✅ 전역 키 추가

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
      scaffoldMessengerKey: rootScaffoldMessengerKey,
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
