import 'package:flutter/material.dart';

class AppColors {
  static const Color mainGreen = Color(0xFF64AB85);
  static const Color deepGrean = Color(0xFF3C7157);
  static const Color lightGreen = Color(0xFFD4EEE2);
  static const Color lighterGreen = Color(0xFFEDF7F2);
  static const Color marineBlue = Color(0xFF2B5288);
  static const Color lightTaube = Color(0xFFE5E0D9);
  static const Color richBlue = Color(0xFF191265);
  static const Color paleGray = Color(0xFFEBEBDF);
  static const Color mustedBlush = Color(0xFFD1ADB6);
  static const Color lightPeriwinkle = Color(0xFFC5D1E8);
}

class AppStyles {
  static const Color keywordChipBackgroundColor = AppColors.paleGray;
  static const keywordChipTextStyle = TextStyle(
    fontSize: 17,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.marineBlue, // 칩의 글자색
  );

  // ✅ Keyword Chip Padding
  static const keywordChipPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 5,
  );
  static final OutlinedBorder keywordChipShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    side: const BorderSide(color: AppColors.lightTaube, width: 0.5),
  );
}

class TextStyles {
  static const smallTextStyle = TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9,
      color: Colors.white);
  static const mediumTextStyle = TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      letterSpacing: 0.9,
      color: Colors.white);
}

// 로그인/회원가입 용 텍스트 필드
class TextFiledStyles {
  static const textStlye = TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9,
      color: Colors.black);

  static const hintStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    color: Color(0xFF9CA3AF),
  );

  static const fillColor = AppColors.lightGreen;

  static const labelStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF777777));

  static const borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.lightGreen, width: 2.0),
  );
  static const focusBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.deepGrean, width: 2.0),
  );

  static const errBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Color.fromARGB(255, 238, 74, 62), width: 2.0),
  );
}

class ButtonStyles {
  /// ElevatedButton의 기본 스타일 정의
  static ButtonStyle smallColoredButtonStyle({
    required BuildContext context,
    double widthFactor = 0.42,
    double height = 40,
    Color foregroundColor = AppColors.deepGrean, // Colors.grey[700]
    Color backgroundColor = AppColors.lighterGreen, // Colors.grey[200]
    Color borderColor = AppColors.lightGreen,
    double borderWidth = 1,
    double borderRadius = 10,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
  }) {
    final double width = MediaQuery.of(context).size.width * widthFactor;

    return ElevatedButton.styleFrom(
      minimumSize: Size(width, height), // 최소 크기
      foregroundColor: foregroundColor, // 글자색
      backgroundColor: backgroundColor,
      // 배경색
      padding: padding, // 내부 여백
      textStyle: const TextStyle(
        fontSize: 16, // medium 설정
        fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 모서리 둥글기
          side: BorderSide(color: borderColor, width: 0.5)),
    );
  }

  static ButtonStyle smallTransparentButtonStyle({
    required BuildContext context,
    double widthFactor = 0.42,
    double height = 40,
    Color foregroundColor = Colors.white, // Colors.grey[700]
    Color backgroundColor = Colors.transparent, // Colors.grey[200]
    Color borderColor = Colors.white,
    double borderWidth = 1,
    double borderRadius = 10,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
  }) {
    final double width = MediaQuery.of(context).size.width * widthFactor;

    return ElevatedButton.styleFrom(
      minimumSize: Size(width, height), // 최소 크기
      foregroundColor: foregroundColor, // 글자색
      backgroundColor: backgroundColor,
      // 배경색
      padding: padding, // 내부 여백
      textStyle: const TextStyle(
        fontSize: 16, // medium 설정
        fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 모서리 둥글기
          side: BorderSide(color: borderColor, width: 0.5)),
    );
  }

  static ButtonStyle miniButtonStyle({
    required BuildContext context,
    double widthFactor = 0.2,
    double height = 20,
    Color foregroundColor = Colors.black, // Colors.grey[700]
    Color backgroundColor = Colors.white, // Colors.grey[200]
    Color borderColor = Colors.black,
    double borderRadius = 5,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
  }) {
    final double width = MediaQuery.of(context).size.width * widthFactor;

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
    required BuildContext context,
    double widthFactor = 0.8,
    double height = 50,
    Color foregroundColor = Colors.black, // Colors.grey[700]
    Color backgroundColor = Colors.white, // Colors.grey[200]
    Color borderColor = Colors.black,
    double borderRadius = 10,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  }) {
    final double width = MediaQuery.of(context).size.width * widthFactor;

    return ElevatedButton.styleFrom(
      minimumSize: Size(width, height), // 최소 크기
      foregroundColor: foregroundColor, // 글자색
      backgroundColor: backgroundColor, // 배경색
      padding: padding, // 내부 여백
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius), // 모서리 둥글기
        side: BorderSide(color: borderColor, width: 0.5),
      ),
    );
  }
}

class SnackBarStyles {
  // ✅ 기본 스타일
  static SnackBar baseSnackBar({
    required String message,
    Color backgroundColor = Colors.black,
    Color textColor = AppColors.deepGrean,
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
      //margin: const EdgeInsets.all(16), // ✅ 화면과의 간격
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // ✅ 둥근 모서리
      ),
      duration: const Duration(seconds: 1), // ✅ 기본 표시 시간
    );
  }

  static SnackBar info(String message) {
    return baseSnackBar(
      message: message,
      backgroundColor: AppColors.lighterGreen,
      textColor: AppColors.deepGrean,
    );
  }
}
