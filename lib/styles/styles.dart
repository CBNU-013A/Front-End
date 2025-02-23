import 'package:flutter/material.dart';

class AppStyles {
  // ✅ Keyword Chip 스타일
  static const keywordChipStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const Color keywordChipBackgroundColor =
      Color.fromRGBO(186, 221, 127, 0.5);
  // ✅ Keyword Chip BoxDecoration
  static final keywordChipDecoration = BoxDecoration(
    color: Colors.green[100], // 칩의 배경색
    borderRadius: BorderRadius.circular(16), // 칩의 둥근 모서리
    border: Border.all(color: Colors.green, width: 1), // 칩의 테두리
  );

  // ✅ Keyword Chip Padding
  static const keywordChipPadding = EdgeInsets.symmetric(
    horizontal: 3,
    vertical: 3,
  );

  
}
