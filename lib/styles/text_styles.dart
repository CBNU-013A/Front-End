// styles/text_styles.dart
import 'package:flutter/material.dart';
import 'dart:io';

final double scale = Platform.isAndroid ? 0.6 : 1.0;

class AppTextStyles {
  static TextStyle appBarTitle = TextStyle(
    fontSize: 25 * scale,
    fontWeight: FontWeight.bold,
    color: Colors.black, // 필요에 따라 색상 변경
  );

  static TextStyle sectionTitle = TextStyle(
      fontSize: 20 * scale,
      fontWeight: FontWeight.w600,
      fontFamily: 'Pretendard',
      color: Colors.black,
      letterSpacing: 0,
      wordSpacing: 0);
}
