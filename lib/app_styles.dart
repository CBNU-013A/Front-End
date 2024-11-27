import 'package:flutter/material.dart';

class AppStyles {
  // 기본 텍스트 스타일
  static const TextStyle titleText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: Colors.red,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  // 공통 TextField 스타일
  static InputDecoration inputDecoration(String label, {bool isError = false}) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isError ? Colors.red : Colors.blue,
        ),
      ),
      labelStyle: isError ? errorText : inputLabel,
    );
  }

  // 버튼 스타일
  static ButtonStyle buttonStyle = ElevatedButton.styleFrom();
}
