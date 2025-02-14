import 'package:flutter/material.dart';
//import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'homePage.dart'; // 로그인 성공 시 홈으로 이동
import 'registerPage.dart'; // 회원가입 페이지로 이동

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일과 비밀번호를 입력하세요.")),
      );
      return;
    }

    final response =
        await ApiService().login(emailController.text, passwordController.text);

    if (response != null && response["success"] == true) {
      String userId = response["user"]["id"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId); // 🔹 로그인된 유저 ID 저장
      await prefs.setBool('saveId', _saveId);

      if (_saveId) {
        await prefs.setString('savedEmail', emailController.text);
      } else {
        await prefs.remove('savedEmail');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      String errorMessage = response?["error"] ?? "로그인 실패! 이메일과 비밀번호를 확인하세요.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
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
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 310),
            TextField(
                cursorColor: const Color.fromRGBO(242, 141, 130, 1),
                controller: emailController,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(242, 141, 130, 1))),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(242, 141, 130, 1))),
                    labelText: "아이디",
                    labelStyle:
                        TextStyle(color: Color.fromRGBO(242, 141, 130, 1)))),

            TextField(
                cursorColor: const Color.fromRGBO(242, 141, 130, 1),
                controller: passwordController,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(242, 141, 130, 1))),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(242, 141, 130, 1))),
                    labelText: "비밀번호",
                    labelStyle: TextStyle(
                      color: Color.fromRGBO(242, 141, 130, 1),
                    )),
                obscureText: true),
            //const SizedBox(height: 10),

            //crossAxisAlignment: CrossAxisAlignment.start,

            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              value: _saveId,
              onChanged: (bool? value) {
                setState(() {
                  _saveId = value ?? false;
                });
              },
              activeColor: const Color.fromRGBO(132, 212, 121, 1),
              title: const Text(
                "아이디 저장",
                style: TextStyle(color: Color.fromRGBO(242, 141, 130, 1)),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 160,
                    vertical: 10,
                  ),
                  backgroundColor: const Color.fromARGB(255, 206, 232, 162)),
              onPressed: _login,
              child: const Text(
                "로그인",
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromRGBO(242, 141, 130, 1),
                ),
              ),
            ),

            const SizedBox(height: 250),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text(
                "회원가입",
                style: TextStyle(
                  color: Color.fromRGBO(242, 141, 130, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
