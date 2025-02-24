import '../pages/loginPage.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 애니메이션 지속 시간
    );

    _scaleAnimation = Tween(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward(); // 애니메이션 시작
    _navigateToLogin();
  }

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  void _navigateToLogin() async {
    // 2초 대기 후 홈 화면으로 이동
    await Future.delayed(const Duration(seconds: 1));

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // 시작 위치 (아래에서 위쪽으로)
          const end = Offset.zero; // 종료 위치
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, // 시작점
            end: Alignment.bottomCenter, // 끝점
            colors: [
              Color(0xFFF7F6FF), // Blue 50
              Color(0xFFEAE8FF), // Blue 100
              Color(0xFFCBC7FF), // Blue 200
              Color(0xFFA39BFF), // Blue 300
              Color(0xFF7B70FF), // Blue 400
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        //color: const Color(0xFFEAE8FF),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                    fontFamily: 'Pretendard',
                    color: Color(0xFF2E2E7A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
