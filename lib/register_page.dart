import 'package:flutter/material.dart';
import 'api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _register() async {
    bool success = await ApiService().register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 성공! 로그인하세요')),
      );
      Navigator.pop(context); // 로그인 화면으로 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패! 다시 시도하세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "이름")),
            TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "이메일")),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "비밀번호"),
                obscureText: true),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _register,
                child: Text("회원가입"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
