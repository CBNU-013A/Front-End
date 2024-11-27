import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_styles.dart';
import 'router.dart';

class JoinWidget extends StatefulWidget {
  const JoinWidget({super.key});

  @override
  State<JoinWidget> createState() => _JoinWidgetState();
}

// class _JoinWidgetState extends State<JoinWidget> {
//   final PageController _pageController = PageController(); // 페이지 전환 컨트롤러
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _birthdateController = TextEditingController();
//   final TextEditingController _yearController = TextEditingController();
//   final TextEditingController _monthController = TextEditingController();
//   final TextEditingController _dayController = TextEditingController();
//   String? _gender; // 기본값

//   bool _isFormValid = false;
//   bool _isFormValid2 = false; // 모든 입력값이 유효한지 확인
//   bool _passwordsMatch = true; // 비밀번호와 비밀번호 확인이 일치하는지 확인

//   void _validateForm() {
//     setState(() {
//       // 모든 입력 필드가 비어있지 않고 비밀번호가 일치하면 true
//       _isFormValid = _idController.text.isNotEmpty &&
//           _passwordController.text.isNotEmpty &&
//           _confirmPasswordController.text.isNotEmpty &&
//           _passwordController.text == _confirmPasswordController.text;

//       // 비밀번호 일치 여부 확인
//       _passwordsMatch =
//           _passwordController.text == _confirmPasswordController.text;
//     });
//   }

//   void _validateForm2() {
//     setState(() {
//       // 이름 유효성 검사
//       final isNameValid2 = _nameController.text.isNotEmpty;

//       // YYYY 유효성 검사
//       final isYearValid = _yearController.text.length == 4 &&
//           int.tryParse(_yearController.text) != null;

//       // MM 유효성 검사
//       final isMonthValid = _monthController.text.length == 2 &&
//           int.tryParse(_monthController.text) != null &&
//           int.parse(_monthController.text) >= 1 &&
//           int.parse(_monthController.text) <= 12;

//       // DD 유효성 검사
//       final isDayValid = _dayController.text.length == 2 &&
//           int.tryParse(_dayController.text) != null &&
//           int.parse(_dayController.text) >= 1 &&
//           int.parse(_dayController.text) <= 31;

//       // 성별 유효성 검사
//       final isGenderValid = _gender != null;

//       // 모든 필드가 유효하면 true
//       isFormValid2 = isNameValid2 &&
//           isYearValid &&
//           isMonthValid &&
//           isDayValid &&
//           isGenderValid;
//     });
//   }

//   void _goToNextPage() {
//     _pageController.nextPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _goToPreviousPage() {
//     _pageController.previousPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE0E0E0),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFE0E0E0),
//         title: const Text("회원가입"),
//       ),
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
//         children: [
//           // 화면 1
//           _buildPage1(),
//           // 화면 2
//           //_buildPage2(),
//           // 화면 2-1
//           _buildPage2_1(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPage1() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             "Create your Account",
//             style: AppStyles.titleText,
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: 300,
//             child: TextField(
//               controller: _idController,
//               onChanged: (_) => _validateForm(), // 입력값 변경 시 유효성 검사
//               decoration: const InputDecoration(
//                 labelText: "아이디",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: 200,
//             child: ElevatedButton(
//               onPressed: () {
//                 // 아이디 중복 확인 로직 추가
//               },
//               child: const Text(
//                 "중복확인",
//                 style: AppStyles.buttonText,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: 300,
//             child: TextField(
//               controller: _passwordController,
//               obscureText: true,
//               onChanged: (_) => _validateForm(), // 입력값 변경 시 유효성 검사
//               decoration: InputDecoration(
//                 labelText: "비밀번호",
//                 border: const OutlineInputBorder(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: 300,
//             child: TextField(
//               controller: _confirmPasswordController,
//               obscureText: true,
//               onChanged: (_) => _validateForm(), // 입력값 변경 시 유효성 검사
//               decoration: InputDecoration(
//                 labelText: "비밀번호 확인",
//                 border: const OutlineInputBorder(),
//                 errorText: _passwordsMatch
//                     ? null
//                     : "비밀번호가 일치하지 않습니다.", // 비밀번호 일치하지 않으면 에러 메시지 표시
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: 100,
//             child: ElevatedButton(
//               onPressed: _isFormValid ? _goToNextPage : null, // 유효할 때만 활성화
//               child: const Text("계속"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPage2() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             "Create your Account",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             controller: _nameController,
//             decoration: const InputDecoration(
//               labelText: "이름",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: _birthdateController,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               labelText: "생년월일 8자리 입력",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   Radio<String>(
//                     value: "여성",
//                     groupValue: _gender,
//                     onChanged: (value) {
//                       setState(() {
//                         _gender = value!;
//                       });
//                     },
//                   ),
//                   const Text("여성"),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Radio<String>(
//                     value: "남성",
//                     groupValue: _gender,
//                     onChanged: (value) {
//                       setState(() {
//                         _gender = value!;
//                       });
//                     },
//                   ),
//                   const Text("남성"),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 간 간격 조정
//             children: [
//               ElevatedButton(
//                 onPressed: _goToPreviousPage,
//                 child: const Text("이전"),
//               ),
//               ElevatedButton(
//                 onPressed: _goToNextPage,
//                 child: const Text("시작하기"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPage2_1() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             "Create your Account",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             controller: _nameController,
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(
//                   RegExp(r'[a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ\s]')), // 문자만 허용
//             ],
//             onChanged: (_) => _validateForm2(),
//             decoration: const InputDecoration(
//               labelText: "이름",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _yearController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(4),
//                   ],
//                   onChanged: (_) => _validateForm2(),
//                   decoration: AppStyles.inputDecoration(
//                     "YYYY",
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _monthController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(2),
//                   ],
//                   onChanged: (_) => _validateForm2(),
//                   decoration: AppStyles.inputDecoration(
//                     "MM",
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _dayController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(2),
//                   ],
//                   onChanged: (_) => _validateForm2(),
//                   decoration: AppStyles.inputDecoration(
//                     "DD",
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   Radio<String>(
//                     value: "여성",
//                     groupValue: _gender,
//                     onChanged: (value) {
//                       setState(() {
//                         _gender = value;
//                         _validateForm();
//                       });
//                     },
//                   ),
//                   const Text("여성"),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Radio<String>(
//                     value: "남성",
//                     groupValue: _gender,
//                     onChanged: (value) {
//                       setState(() {
//                         _gender = value;
//                         _validateForm();
//                       });
//                     },
//                   ),
//                   const Text("남성"),
//                 ],
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: _isFormValid2
//                 ? () {
//                     // 회원가입 완료 로직 추가
//                     print("모든 입력이 완료되었습니다.");
//                   }
//                 : null, // 유효하지 않을 경우 비활성화
//             child: const Text("시작하기"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // 메모리 누수 방지
//     _nameController.dispose();
//     _yearController.dispose();
//     _monthController.dispose();
//     _dayController.dispose();
//     super.dispose();
//   }
// }

class _JoinWidgetState extends State<JoinWidget> {
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _dayController = TextEditingController();
  String? _gender;
  final TextEditingController _idController = TextEditingController();
  bool _isFormValid = false;
  bool _isFormValid2 = false;
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  // 상태 초기화
  final PageController _pageController = PageController();

  final TextEditingController _passwordController = TextEditingController();
  bool _passwordsMatch = true;
  final TextEditingController _yearController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  // 페이지 전환 로직
  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 첫 번째 페이지 유효성 검사
  void _validateForm() {
    setState(() {
      _isFormValid = _idController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;

      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  // 두 번째 페이지 유효성 검사
  void _validateForm2() {
    setState(() {
      final isNameValid = _nameController.text.isNotEmpty;
      final isYearValid = _yearController.text.length == 4 &&
          int.tryParse(_yearController.text) != null;
      final isMonthValid = _monthController.text.length == 2 &&
          int.tryParse(_monthController.text) != null &&
          int.parse(_monthController.text) >= 1 &&
          int.parse(_monthController.text) <= 12;
      final isDayValid = _dayController.text.length == 2 &&
          int.tryParse(_dayController.text) != null &&
          int.parse(_dayController.text) >= 1 &&
          int.parse(_dayController.text) <= 31;
      final isGenderValid = _gender != null;

      _isFormValid2 = isNameValid &&
          isYearValid &&
          isMonthValid &&
          isDayValid &&
          isGenderValid;
    });
  }

  // 페이지 1 UI
  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Create your Account", style: AppStyles.titleText),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _idController,
              onChanged: (_) => _validateForm(),
              decoration: const InputDecoration(
                labelText: "아이디",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              onChanged: (_) => _validateForm(),
              decoration: const InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              onChanged: (_) => _validateForm(),
              decoration: InputDecoration(
                labelText: "비밀번호 확인",
                border: const OutlineInputBorder(),
                errorText: _passwordsMatch ? null : "비밀번호가 일치하지 않습니다.",
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isFormValid ? _goToNextPage : null,
            child: const Text("계속"),
          ),
        ],
      ),
    );
  }

  // 페이지 2 UI
  Widget _buildPage2_1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Create your Account", style: AppStyles.titleText),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]')),
            ],
            onChanged: (_) => _validateForm2(),
            decoration: const InputDecoration(
              labelText: "이름",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (_) => _validateForm2(),
                  decoration: AppStyles.inputDecoration("YYYY"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _monthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: (_) => _validateForm2(),
                  decoration: AppStyles.inputDecoration("MM"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _dayController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: (_) => _validateForm2(),
                  decoration: AppStyles.inputDecoration("DD"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Radio<String>(
                      value: "여성",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                          _validateForm2();
                        });
                      }),
                  const Text("여성"),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "남성",
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                        _validateForm2();
                      });
                    },
                  ),
                  const Text("남성"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isFormValid2
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("회원가입 성공")),
                    );
                    Navigator.pushNamed(context, AppRoutes.login);
                  }
                : null,
            child: const Text("시작하기"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E0E0),
        title: const Text("회원가입"),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
        children: [
          // 화면 1
          _buildPage1(),
          // 화면 2
          //_buildPage2(),
          // 화면 2-1
          _buildPage2_1(),
        ],
      ),
    );
  }
}
