import 'package:flutter/material.dart';
import 'login2.dart';
import 'login.dart';
import 'joinus.dart';

class AppRoutes {
  // 라우트 이름 정의
  static const String home = '/home';
  static const String login = '/login';
  static const String join = '/join';

  // 라우트 맵
  static Map<String, WidgetBuilder> routes = {
    home: (context) =>  const Splash(),
    login: (context) => const LoginWidget(),
    join: (context) => const JoinWidget(),
  };
}