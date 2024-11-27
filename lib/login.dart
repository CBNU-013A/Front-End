import 'package:flutter/material.dart';
import 'app_styles.dart'; // 스타일 파일 import
import 'package:final_project/joinus.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isError = false;
  String _errorMessage = "";

  void _handleLogin() {
    setState(() {
      if (_idController.text == "admin" && _passwordController.text == "1234") {
        _isError = false;
        _errorMessage = "";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );
      } else {
        _isError = true;
        _errorMessage = "아이디 또는 비밀번호를 다시 확인하세요.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width / 2 - 50, // 화면 중앙 정렬
            child: Container(
              width: 100,
              height: 50,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  "Logo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // 제목
                    const Text(
                      "Login to your Account",
                      style: AppStyles.titleText,
                    ),
                    const SizedBox(height: 20),

                    // 아이디 입력 필드
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _idController,
                        decoration: AppStyles.inputDecoration(
                          "아이디",
                          isError: _isError,
                        ),
                        onSubmitted: (value) {
                          // 비밀번호 입력 후 엔터를 누르면 로그인 동작
                          _handleLogin();
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    // 비밀번호 입력 필드
                    const SizedBox(height: 20),
                    // 비밀번호 입력 필드
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "비밀번호",
                          border: const OutlineInputBorder(),
                          errorText: _isError ? _errorMessage : null,
                        ),
                        onSubmitted: (value) {
                          // 비밀번호 입력 후 엔터를 누르면 로그인 동작
                          _handleLogin();
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 에러 메시지
                    if (_isError)
                      Text(
                        _errorMessage,
                        style: AppStyles.errorText,
                      ),
                    const SizedBox(height: 20),
                    // 로그인 버튼
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        //style: AppStyles.buttonStyle,
                        child: const Text(
                          "Sign in",
                          style: AppStyles.buttonText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 회원가입 안내
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don’t have an account? "),
                        GestureDetector(
                          onTap: () {
                            // 회원가입 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const JoinWidget()),
                            );
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
