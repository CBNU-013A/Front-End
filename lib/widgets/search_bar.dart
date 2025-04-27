import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project/pages/detailPage.dart';
import 'package:final_project/pages/searchPage.dart';

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
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          icon: const Icon(CupertinoIcons.search, color: Colors.grey),
          hintText: '여행지를 검색하세요',
          border: InputBorder.none,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}
