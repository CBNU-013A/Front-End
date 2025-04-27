import 'package:flutter/material.dart';
//import 'package:http/http.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'homePage.dart'; // 로그인 성공 시 홈으로 이동
import 'registerPage.dart'; // 회원가입 페이지로 이동
import '../styles/styles.dart';

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
    _loadSavedId();
  }

  // SharedPreferences에서 저장된 이메일 불러오기
  void _loadSavedId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saveId = prefs.getBool('saveId') ?? false;
      if (_saveId) {
        emailController.text = prefs.getString('savedEmail') ?? "";
      }
    });
  }

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // ✅ 디버깅 로그 추가 (입력 값 확인)
    debugPrint("📌 로그인 요청: 이메일=$email, 비밀번호=$password");
    if (email.isEmpty || password.isEmpty) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("🫤 아이디와 비밀번호를 입력하세요."),
      );
      return;
    }

    final response =
        await ApiService().login(emailController.text, passwordController.text);

    if (response != null && response["message"] == "로그인 성공") {
      String userId = response["user"]["id"];
      String userName = response["user"]["name"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId); // 🔹 로그인된 유저 ID 저장
      await prefs.setBool('saveId', _saveId);
      await prefs.setString("userName", userName);

      if (_saveId) {
        await prefs.setString('savedEmail', emailController.text);
      } else {
        await prefs.remove('savedEmail');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("😎 로그인 성공!"),
      );
    } else {
      String errorMessage = response?["error"] ?? "로그인 실패! 이메일과 비밀번호를 확인하세요.";
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
            const Expanded(
              // 여기에 로고를 넣어요
              child: Center(
                child: Text("로고를 넣어용"),
              ),
            ),
            //이메일 필드
            TextField(
              style: TextFiledStyles.textStlye,
              cursorColor: AppColors.deepGrean,
              controller: emailController,
              decoration: const InputDecoration(
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
                decoration: const InputDecoration(
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
                      onChanged: (bool? value) {
                        setState(() {
                          _saveId = value ?? false;
                        });
                      },
                      activeColor: AppColors.lighterGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                    const Text(
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
                  child: const Text(
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
