import 'package:flutter/material.dart';
import '../api_service.dart';
import 'loginPage.dart'; // 회원가입 후 로그인 페이지로 이동
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  //final TextEditingController birthdateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  

  void _showDatePicker(BuildContext context) {
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
                onPressed: () => Navigator.pop(context), // 팝업 닫기
              ),
            ),
            // 날짜 선택기
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date, // 연, 월, 일 모드
                initialDateTime: selectedDate,
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
    );
  }

  bool _isPasswordVisible = false;

  void _register() async {
    String formattedDate =
        DateFormat('yyyy-MM-dd').format(selectedDate); // 날짜 포맷 적용

    debugPrint("📌registerPage.dart : 회원가입 요청 데이터:");
    debugPrint("이름: ${nameController.text}");
    debugPrint("이메일: ${emailController.text}");
    debugPrint("비밀번호: ${passwordController.text}");
    debugPrint("생년월일: $selectedDate\n");

    bool success = await ApiService().register(
      nameController.text,
      emailController.text,
      passwordController.text,
      selectedDate,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 성공! 로그인하세요.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 실패! 다시 시도하세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

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

      home: Scaffold(
        //appBar: AppBar(title:,),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                  cursorColor: const Color.fromRGBO(242, 141, 130, 1),
                  controller: nameController,
                  decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(242, 141, 130, 1))),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(242, 141, 130, 1))),
                      labelText: "이름",
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(242, 141, 130, 1)))),
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
                decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromRGBO(242, 141, 130, 1))),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromRGBO(242, 141, 130, 1))),
                  labelText: "비밀번호",
                  labelStyle:
                      const TextStyle(color: Color.fromRGBO(242, 141, 130, 1)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color.fromRGBO(242, 141, 130, 1),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "생년월일",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromRGBO(242, 141, 130, 1),
                    ),
                  ),
                  // const SizedBox(
                  //   width: 15,
                  // ),
                  Text(
                    '${selectedDate.year}년   ${selectedDate.month}월   ${selectedDate.day}일',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    height: 36,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              Color.fromRGBO(242, 141, 130, 1)), // 테두리를 블랙으로 설정
                      borderRadius:
                          BorderRadius.circular(8), // 버튼 모서리를 둥글게 (원하지 않으면 제거)
                    ),
                    child: CupertinoButton(
                      alignment: Alignment.center,

                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 3),
                      minSize: 33,
                      color:
                          Colors.transparent, // 배경색을 투명하게 설정 (원하면 다른 색으로 변경 가능)
                      child: const Text(
                        '선택하기',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black, // 텍스트 색상을 블랙으로 설정
                        ),
                      ),
                      onPressed: () => _showDatePicker(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 150,
                        vertical: 10,
                      ),
                      backgroundColor:
                          const Color.fromARGB(255, 206, 232, 162)),
                  onPressed: () {
                    _register();
                  },
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(242, 141, 130, 1),
                    ),
                  ),
                ),
              ),
              Align(
                child: TextButton(
                  child: const Text(
                    "뒤로가기",
                    style: TextStyle(color: Color.fromRGBO(242, 141, 130, 1)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
