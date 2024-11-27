import 'login.dart';
import 'package:flutter/material.dart';
import 'router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      initialRoute: AppRoutes.home, // 초기 화면 설정
      routes: AppRoutes.routes,    // 라우트 연결
    );
  }
}
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

// class _SplashState extends State<Splash> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToHome();
//   }

//   void _navigateToHome() async {
//   // 2초 대기 후 홈 화면으로 이동
//   await Future.delayed(const Duration(seconds: 2));

//   Navigator.pushReplacement(
//     context,
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(0.0,1.0); // 시작 위치 (아래에서 위쪽으로)
//         const end = Offset.zero;       // 종료 위치
//         const curve = Curves.easeInOut;

//         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);

//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     ),
//   );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.blue, // 배경 색상 설정
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Welcome!",
//                 style: TextStyle(
//                   fontSize: 24,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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

    _scaleAnimation = Tween(begin: 1.0, end: 2.0).animate(
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
            const LoginWidget(),
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
        color: Colors.blue,
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
                    color: Colors.white,
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
