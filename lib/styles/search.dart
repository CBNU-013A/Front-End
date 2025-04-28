import 'package:flutter/material.dart';
import './styles.dart';

class SearcherStyles {
  static const EdgeInsets containerPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0);
  static const Color cursorColor =
      Colors.black54; // Replace with your desired color
  static BoxDecoration get containerDecoration => BoxDecoration(
        color: AppColors.lightGreen, // You can replace this with your app color
        borderRadius: BorderRadius.circular(15),
      );

  static const hintTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 16,
  );
}
