// main.dart
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home/homePage.dart'; // 홈 페이지
import 'pages/auth/loginPage.dart';
import 'widgets/splashLogo.dart'; // 로그인 페이지
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart'; //위도 경도 가져옴
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository.initialize(appKey: 'c4e1eb2e4df9471dd1f08410194cfd13');

  KakaoSdk.init(
    nativeAppKey: '2a9e7d21868ff0932e17ad3708dcbe9b',
    javaScriptAppKey: 'c4e1eb2e4df9471dd1f08410194cfd13',
  );

  // Kakao SDK 초기화 여부 확인
  debugPrint("✅ kakaoSdk 초기화 ");
  await dotenv.load(); //비동기 로딩 (async)

  runApp(const MyApp());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(); // ✅ 전역 키 추가

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Widget _startScreen = const CircularProgressIndicator(); // 로딩 UI

  @override
  void initState() {
    super.initState();
    _checkAutoLogin(); // 자동 로그인 체크
    _printCurrentLocation(); //현재 위치 가져오기
  }

  void _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스 비활성화');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한 거부');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("위치 권한 영구 거부");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.country}';

        debugPrint("✅ 현재 위치 주소: $address");
      } else {
        debugPrint("❗ 주소 정보 없음");
      }
    } catch (e) {
      debugPrint("❗ 역지오코딩 실패: $e");
    }
  }

  void _printCurrentLocation() async {
    try {
      Position position = await _getCurrentLocation();
      _getAddressFromLatLng(position.latitude, position.longitude);
      debugPrint("✅ 현재 위치: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint("❗ 위치 가져오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/homepage': (context) => const HomePage(), // 🔥 홈 라우트 등록
      },
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
