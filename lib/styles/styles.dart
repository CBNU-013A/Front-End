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

class TextFiledStyles {
  static const textStlye = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9,
      color: Colors.black);

  static const labelStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF777777));

  static const borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Color(0xFF4738D7), width: 2.0),
  );
}

class ButtonStyles {
  /// ElevatedButton의 기본 스타일 정의
  static ButtonStyle smallButtonStyle({
    double width = 50,
    double height = 40,
    Color foregroundColor = Colors.black, // Colors.grey[700]
    Color backgroundColor = Colors.white, // Colors.grey[200]
    Color borderColor = Colors.black,
    double borderRadius = 5,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
  }) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(width, height), // 최소 크기
      foregroundColor: foregroundColor, // 글자색
      backgroundColor: backgroundColor,
      // 배경색
      padding: padding, // 내부 여백
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 모서리 둥글기
          side: BorderSide(color: borderColor, width: 0.5)),
    );
  }

  static ButtonStyle bigButtonStyle({
    double width = 180,
    double height = 35,
    Color foregroundColor = Colors.black, // Colors.grey[700]
    Color backgroundColor = Colors.white, // Colors.grey[200]
    Color borderColor = Colors.black,
    double borderRadius = 10,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  }) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(width, height), // 최소 크기
      foregroundColor: foregroundColor, // 글자색
      backgroundColor: backgroundColor,
      // 배경색
      padding: padding, // 내부 여백
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 모서리 둥글기
          side: BorderSide(color: borderColor, width: 0.5)),
    );
  }
}

class SnackBarStyles {
  // ✅ 기본 스타일
  static SnackBar baseSnackBar({
    required String message,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    IconData? icon,
  }) {
    return SnackBar(
      content: Row(
        children: [
          if (icon != null) Icon(icon, color: textColor, size: 20), // 아이콘 옵션
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating, // ✅ 화면에 떠있는 형태
      margin: const EdgeInsets.all(16), // ✅ 화면과의 간격
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // ✅ 둥근 모서리
      ),
      duration: const Duration(seconds: 3), // ✅ 기본 표시 시간
    );
  }

  static SnackBar info(String message) {
    return baseSnackBar(
      message: message,
      backgroundColor: Color(0xFF4738D7),
      textColor: Colors.white,
    );
  }
}
