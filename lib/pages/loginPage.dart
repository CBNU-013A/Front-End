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

    if (response != null && response["success"] == true) {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              style: TextFiledStyles.textStlye,
              cursorColor: const Color(0xFF4738D7),
              controller: emailController,
              decoration: const InputDecoration(
                  border: TextFiledStyles.borderStyle,
                  focusedBorder: TextFiledStyles.borderStyle,
                  labelText: "아이디",
                  labelStyle: TextFiledStyles.labelStyle),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
                style: TextFiledStyles.textStlye,
                cursorColor: const Color(0xFF4738D7),
                controller: passwordController,
                decoration: const InputDecoration(
                  border: TextFiledStyles.borderStyle,
                  focusedBorder: TextFiledStyles.borderStyle,
                  labelText: "비밀번호",
                  labelStyle: TextFiledStyles.labelStyle,
                ),
                obscureText: true),
            //const SizedBox(height: 10),

            //crossAxisAlignment: CrossAxisAlignment.start,

            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              value: _saveId,
              onChanged: (bool? value) {
                setState(() {
                  _saveId = value ?? false;
                });
              },
              activeColor: const Color(0xFF4738D7),
              title: const Text(
                "아이디 저장",
                style: TextFiledStyles.labelStyle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyles.bigButtonStyle(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    "회원가입",
                    style: TextFiledStyles.textStlye,
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyles.bigButtonStyle(
                      backgroundColor: Colors.black),
                  onPressed: _login,
                  child: Text(
                    "로그인",
                    style:
                        TextFiledStyles.textStlye.copyWith(color: Colors.white),
                  ),
                ),
              ],
            )

            //const SizedBox(height: 250),
          ],
        ),
      ),
    );
  }
}
