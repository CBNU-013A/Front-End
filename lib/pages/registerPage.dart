import 'package:flutter/material.dart';
import '../api_service.dart';
import 'loginPage.dart'; // 회원가입 후 로그인 페이지로 이동
import 'package:flutter_localizations/flutter_localizations.dart';

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

  bool _isPasswordVisible = false;

  // ✅ 연도 리스트 생성
  final List<int> _years =
      List.generate(100, (index) => DateTime.now().year - index);
  final List<int> _months = List.generate(12, (index) => index + 1);
  final List<int> _days = List.generate(31, (index) => index + 1);

  List<int> getDaysInMonth(int year, int month) {
    return List.generate(
        DateTime(year, month + 1, 0).day, (index) => index + 1);
  }

  int selectedYear = DateTime.now().year;
  int selectedMonth = 1;
  int selectedDay = 1;

  void _register() async {
    DateTime birthdate = DateTime(
      selectedYear,
      selectedMonth,
      selectedDay,
    );

    debugPrint("📌registerPage.dart : 회원가입 요청 데이터:");
    debugPrint("이름: ${nameController.text}");
    debugPrint("이메일: ${emailController.text}");
    debugPrint("비밀번호: ${passwordController.text}");
    debugPrint("생년월일: $birthdate\n");

    bool success = await ApiService().register(
      nameController.text,
      emailController.text,
      passwordController.text,
      birthdate,
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

                  DropdownButton<int>(
                    value: selectedYear,
                    items: _years.map((year) {
                      return DropdownMenuItem(
                          value: year, child: Text("$year년"));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                  // const SizedBox(
                  //   width: 15,
                  // ),
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: _months.map((month) {
                      return DropdownMenuItem(
                          value: month, child: Text("$month월"));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                  // const SizedBox(
                  //   width: 15,
                  // ),
                  DropdownButton<int>(
                    value: selectedDay,
                    items: _days.map((day) {
                      return DropdownMenuItem(value: day, child: Text("$day일"));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value!;
                      });
                    },
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
                      fontSize: 15,
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
