// pages/auth/LoginPage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/main.dart';
import 'package:final_project/services/auth_service.dart';
import 'package:final_project/pages/home/HomePage.dart';
import 'package:final_project/pages/auth/RegisterPage.dart';
import 'package:final_project/styles/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:final_project/services/like_service.dart';
import 'package:final_project/pages/onboarding/RandomLocationPage.dart';
import 'package:final_project/pages/home/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _saveId = false;

  @override
  void initState() {
    super.initState();
    _loadSavedId(); //아이디 저장하기
  }

  // 아이디 저장하기
  void _loadSavedId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('saveId');
    final email = prefs.getString('savedEmail') ?? "";
    debugPrint("🔁 불러온 saveId: $saved");
    debugPrint("🔁 불러온 savedEmail: $email");

    setState(() {
      _saveId = prefs.getBool('saveId') ?? false;
      if (_saveId) {
        emailController.text = email;
      }
    });
  }

  // 로그인
  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("아이디와 비밀번호를 입력하세요!"),
      );
      return;
    }
    bool success = await AuthService().login(email, password);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      if (_saveId) {
        await prefs.setString('savedEmail', email);
      } else {
        await prefs.remove('savedEmail');
      }
      // ✅ 로그인 성공 분기: 좋아요가 없으면 랜덤 선택 페이지, 있으면 홈으로
      final userId = prefs.getString('userId') ?? '';
      final token = prefs.getString('token') ?? '';
      List<dynamic>? likes;
      try {
        likes = await LikeService().loadUserLikePlaces(userId, token);
      } catch (e) {
        likes = [];
        debugPrint('❌ 좋아요 조회 실패: $e');
      }

      if (!mounted) return;

      if (likes == null || likes.isEmpty) {
        // 좋아요 항목이 없을 경우 → 랜덤 선택 페이지
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RandomLocationPage()),
          (route) => false,
        );
      } else {
        // 좋아요 항목이 있을 경우 → 홈 화면
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }

      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("😎 로그인 성공!"),
      );
      debugPrint("loginpage : 로그인 성공 : $email");
    } else {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("🫤 아이디와 비밀번호를 확인하세요."),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: const Text("로그인")),
        body: Container(
      decoration: const BoxDecoration(color: AppColors.mainGreen),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // 여기에 로고를 넣어요
              child: Center(
                child: SizedBox(
                    height: 120,
                    child: SvgPicture.asset(
                      'assets/Logo.svg',
                      color: AppColors.lightWhite, // 경로가 맞는지 확인
                    )),
              ),
            ),

            //이메일 필드
            TextField(
              style: TextFiledStyles.textStlye,
              cursorColor: AppColors.deepGrean,
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: TextFiledStyles.fillColor, // 배경 색상 설정
                border: TextFiledStyles.borderStyle,
                enabledBorder: TextFiledStyles.borderStyle,
                focusedBorder: TextFiledStyles.focusBorderStyle,
                hintText: '이메일을 입력하세요',
                hintStyle: TextFiledStyles.hintStyle,
              ),
              textAlignVertical: TextAlignVertical.center, // 텍스트 정렬
              minLines: 1, // 최소 줄 수
              maxLines: 1, // 최대 줄 수 // 높이 조정
            ),
            const SizedBox(
              height: 10,
            ),
            // 비밀번호 필드
            TextField(
                style: TextFiledStyles.textStlye,
                cursorColor: AppColors.deepGrean,
                controller: passwordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: TextFiledStyles.fillColor,
                  border: TextFiledStyles.borderStyle,
                  enabledBorder: TextFiledStyles.borderStyle,
                  focusedBorder: TextFiledStyles.focusBorderStyle,
                  hintText: '비밀번호를 입력하세요',
                  hintStyle: TextFiledStyles.hintStyle,
                ),
                textAlignVertical: TextAlignVertical.center, // 텍스트 정렬
                minLines: 1, // 최소 줄 수
                maxLines: 1, // 최대 줄 수 // 높이 조정
                obscureText: true),

            // 아이디 저장 체크 박스
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _saveId,
                      onChanged: (bool? value) async {
                        final prefs = await SharedPreferences.getInstance();
                        setState(() {
                          _saveId = value ?? false;
                        });
                        await prefs.setBool('saveId', _saveId);
                      },
                      activeColor: AppColors.lighterGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      "아이디 저장",
                      style: TextStyles.smallTextStyle,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("아직 페이지 구현을 못했어요 ㅠ.ㅠ")),
                    );
                  },
                  child: Text(
                    "비밀번호가 기억이 안나요",
                    style: TextStyles.smallTextStyle,
                  ),
                ),
              ],
            ),

            // 회원가입 버튼, 로그인 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyles.smallTransparentButtonStyle(
                      context: context),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    "회원가입",
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyles.smallColoredButtonStyle(context: context),
                  onPressed: _login,
                  child: const Text("로그인"),
                ),
              ],
            )

            //const SizedBox(height: 250),
          ],
        ),
      ),
    ));
  }
}
