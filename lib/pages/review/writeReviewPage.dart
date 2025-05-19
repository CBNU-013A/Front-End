// pages/review/writeReviewPage.dart
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class WriteReviewPage extends StatefulWidget {
  final String place;
  final String? initialText;

  const WriteReviewPage({Key? key, required this.place, this.initialText = ""})
      : super(key: key);

  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialText ?? '';
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      // Handle review submission logic here
      print('Title: ${_titleController.text}');
      print('Content: ${_contentController.text}');
      print('Rating: $_rating');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightWhite,
        actions: [
          const SizedBox(width: 8.0), // Add spacing before the button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppColors.lightWhite; // Change color when pressed
                  }
                  return AppColors.lightWhite; // Default color
                },
              ),
            ),
            onPressed: () {
              final String reviewText = _contentController.text.trim();
              if (reviewText.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBarStyles.info('리뷰 등록 완료 😎'),
                );
                if (mounted) {
                  Navigator.pop(context, reviewText);
                }
                // 작성한 내용 넘기기
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리뷰를 입력해주세요!')),
                );
              }
            },
            child: const Text(
              '작성하기',
              style: TextStyle(color: AppColors.deepGrean),
            ),
          ),
          const SizedBox(width: 8.0), // Add spacing after the button
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLength: 100,
          maxLines: 10,
          //expands: true,
          textAlignVertical: TextAlignVertical.top,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText:
                '욕설, 비방 등 상대방을 불쾌하게 하는 의견은 남기지 말아주세요. 신고를 당하면 서비스 이용이 제한될 수 있어요.',
            hintMaxLines: 3,
          ),
        ),
      ),
    );
  }
}
