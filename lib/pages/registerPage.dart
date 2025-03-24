import 'dart:async';

import 'package:flutter/material.dart';
import '../api_service.dart';
import 'loginPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../styles/styles.dart';
import '../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  bool _isDatePickerOpen = false;
  bool _isIDCheck = true;
  bool _isPasswordVisible = false;
  bool _isPasswordCheck = true;

  void _showDatePicker(BuildContext context) {
    setState(() {
      _isDatePickerOpen = true; // ✅ DatePicker 열릴 때 true로 설정
    });
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            // 완료 버튼
            SizedBox(
              height: 50,
              child: CupertinoButton(
                child: const Text('완료',
                    style: TextStyle(color: CupertinoColors.activeBlue)),
                onPressed: () {
                  setState(() {
                    _isDatePickerOpen = false; // ✅ 닫힐 때 false로 설정
                  });
                  Navigator.pop(context); // 팝업 닫기
                }, // 팝업 닫기
              ),
            ),
            // 날짜 선택기
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date, // 연, 월, 일 모드
                initialDateTime: selectedDate ?? DateTime.now(),
                minimumDate: DateTime(1900, 1, 1), // 최소 날짜
                maximumDate: DateTime.now(), // 최대 날짜
                onDateTimeChanged: (DateTime date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // ✅ 사용자가 바깥을 클릭하여 팝업을 닫았을 때
      setState(() {
        _isDatePickerOpen = false;
      });
    });
  }

  // 회원가입 요청
  void _register() async {
    debugPrint("📌registerPage.dart : 회원가입 요청 데이터:");
    debugPrint("이름: ${nameController.text}");
    debugPrint("이메일: ${emailController.text}");
    debugPrint("비밀번호: ${passwordController.text}");
    debugPrint("비밀번호 확인: ${passwordCheckController.text}");
    debugPrint("생년월일: $selectedDate\n");

    bool success = await ApiService().register(
      nameController.text,
      emailController.text,
      passwordController.text,
      selectedDate,
    );

    if (!mounted) return;

    if (success) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("😎 회원가입 성공 !"),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .hideCurrentSnackBar(); // ✅ 페이지 이동 전 스낵바 숨기기
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("😓 회원가입 실패 !"),
      );
      _isIDCheck = false;
    }
  }

// 아이디 중복 확인
  void _idcheck() async {
    debugPrint("이메일 체크: ${emailController.text}\n");

    final response = await http.get(Uri.parse(
        'http://localhost:5001/check-email?email=${emailController.text}'));

    if (response.statusCode == 200) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("사용 가능한 아이디입니다."),
      );
      setState(() {
        _isIDCheck = true;
      });
    } else if (response.statusCode == 400) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("이미 사용 중인 아이디입니다."),
      );
      setState(() {
        _isIDCheck = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isIDCheck = true;
      });
      emailController.clear();
    }
  }

// 비밀번호 확인
  void _passwordCheck() {
    if (passwordController.text != passwordCheckController.text) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("비밀번호가 일치하지 않습니다."),
      );
      setState(() {
        _isPasswordCheck = false;
      });
      Timer(const Duration(seconds: 2), () {
        setState(() {
          _isPasswordCheck = true;
        });
      });
    } else {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBarStyles.info("비밀번호가 일치합니다."),
      );
      setState(() {
        _isPasswordCheck = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title:,),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //아이디 입력
            TextField(
                style: TextFiledStyles.textStlye,
                cursorColor: const Color(0xFF4738D7),
                controller: emailController,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                    border: TextFiledStyles.borderStyle,
                    focusedBorder: _isIDCheck
                        ? TextFiledStyles.borderStyle
                        : TextFiledStyles.errBorderStyle,
                    labelText: "아이디",
                    labelStyle: TextFiledStyles.labelStyle,
                    suffixIconConstraints: const BoxConstraints(
                      minHeight: 30, // 버튼의 최소 너비
                      // 버튼의 최소 높이
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(
                        right: 8,
                      ),
                      height: 30,
                      child: ElevatedButton(
                        style: ButtonStyles.smallButtonStyle(),
                        onPressed: () {
                          _idcheck();
                        },
                        child: const Text(
                          "중복확인",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                    ))),

            const SizedBox(height: 16.0),
            //비밀번호 입력
            TextField(
              style: TextFiledStyles.textStlye,
              cursorColor: const Color(0xFF4738D7),
              controller: passwordController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                border: TextFiledStyles.borderStyle,
                focusedBorder: TextFiledStyles.borderStyle,
                labelText: "비밀번호",
                labelStyle: TextFiledStyles.labelStyle,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey[800],
                    size: 15,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),

            const SizedBox(height: 16.0),
            TextField(
              style: TextFiledStyles.textStlye,
              cursorColor: const Color(0xFF4738D7),
              controller: passwordCheckController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                border: TextFiledStyles.borderStyle,
                focusedBorder: _isPasswordCheck
                    ? TextFiledStyles.borderStyle
                    : TextFiledStyles.errBorderStyle,
                labelText: "비밀번호 확인",
                labelStyle: TextFiledStyles.labelStyle,
                suffixIconConstraints: const BoxConstraints(
                  minHeight: 30, // 버튼의 최소 너비
                  // 버튼의 최소 높이
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(
                    right: 8,
                  ),
                  height: 30,
                  child: ElevatedButton(
                    style: ButtonStyles.smallButtonStyle(),
                    onPressed: () {
                      _passwordCheck();
                    },
                    child: const Text(
                      "확인",
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),

            const SizedBox(height: 16.0),

            //이름 입력
            TextField(
                style: TextFiledStyles.textStlye,
                cursorColor: const Color(0xFF4738D7),
                controller: nameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20, 12, 12, 10),
                  border: TextFiledStyles.borderStyle,
                  focusedBorder: TextFiledStyles.borderStyle,
                  labelText: "이름",
                  labelStyle: TextFiledStyles.labelStyle,
                )),
            const SizedBox(height: 16.0),
            //생년월일 입력
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isDatePickerOpen
                      ? const Color(0xFF4738D7) // ✅ DatePicker가 열리면 보라색 테두리
                      : Colors.grey[600]!,
                  width: _isDatePickerOpen ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text('생년월일',
                  // style: TextFiledStyles.labelStyle,),
                  const Text(
                    "생년월일",
                    style: TextFiledStyles.labelStyle,
                  ),
                  Text(
                    !DateUtils.isSameDay(
                            selectedDate, DateTime.now()) // ✅ 날짜가 같으면
                        ? ' ${selectedDate!.year}년\t${selectedDate!.month}월\t${selectedDate!.day}일'
                        : ' ', // ✅ 기본값
                    style: TextFiledStyles.textStlye,
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyles.smallButtonStyle(),
                      onPressed: () => _showDatePicker(context),
                      child: const Text(
                        "선택하기",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyles.bigButtonStyle(),
                  child: const Text(
                    "뒤로가기",
                    style: TextFiledStyles.textStlye,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                ),
                ElevatedButton(
                  style: ButtonStyles.bigButtonStyle(
                      backgroundColor: Colors.grey[900]!),
                  onPressed: () {
                    _register();
                  },
                  child: Text(
                    "회원가입",
                    style:
                        TextFiledStyles.textStlye.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
