// widgets/search_bar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../styles/search.dart';
import '../styles/styles.dart';
import 'package:final_project/pages/location/DetailPage.dart';
import 'package:final_project/pages/home/SearchPage.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;

  const SearchBar({
    super.key,
    required this.controller,
    this.initialValue,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (initialValue != null) {
      controller.text = initialValue!;
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: SearcherStyles.containerDecoration,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: const InputDecoration(
          hintText: '여행지를 검색하세요',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
