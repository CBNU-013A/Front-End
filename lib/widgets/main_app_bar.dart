// widgets/main_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/styles/text_styles.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.lighterGreen,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: AppBar(
        backgroundColor: AppColors.lighterGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.lighterGreen,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12, 12, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: AppTextStyles.appBarTitle),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
