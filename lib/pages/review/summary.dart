// pages/review/summary.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../styles/styles.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';
    
class SummaryWidget extends StatefulWidget {
  const SummaryWidget({Key? key, required this.place}) : super(key: key);

  final String place;

  @override
  _SummaryWidgetState createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  Map<String, dynamic>? _matchedPlace;

  @override
  void initState() {
    super.initState();
    _loadPlaceData();
  }

  Future<void> _loadPlaceData() async {
    try {
      final String placeName = Uri.encodeComponent(widget.place);
      final response = await http.get(
        Uri.parse('$baseUrl/api/location/$placeName'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _matchedPlace = data;
        });
      } else {
        throw Exception('Failed to load place data');
      }
    } catch (e) {
      debugPrint("❗ 서버 통신 중 오류 발생: $e");
    }
  }

  Widget _buildSummarySection(Map<String, dynamic> data) {
    final List<dynamic> keywords = data['keywords'] ?? [];
    final List<dynamic> reviews = data['review'] ?? [];
    keywords.sort((a, b) =>
        (b['sentiment']['total'] ?? 0).compareTo(a['sentiment']['total'] ?? 0));
    if (keywords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('관련 키워드가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...keywords
              .map((keyword) {
                final String name = keyword['name'].toString();
                final int total = keyword['sentiment']['total'] ?? 0;
                final int pos = keyword['sentiment']['pos'] ?? 0;
                final int neg = keyword['sentiment']['neg'] ?? 0;
                final int neu = keyword['sentiment']['neu'] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //const SizedBox(height: 4),
                      LayoutBuilder(builder: (context, constraints) {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${((pos / total) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 12),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: AppColors.lighterGreen,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: pos / total * 100,
                                    decoration: const BoxDecoration(
                                      color: AppColors.successGreen,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                '$name ',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.deepGrean),
                              ),
                            ]);
                      }),
                      const SizedBox(height: 4),
                    ],
                  ),
                );
              })
              .take(5)
              .toList(),
          const SizedBox(height: 20),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return _matchedPlace == null
        ? const Center(child: CircularProgressIndicator())
        : _buildSummarySection(_matchedPlace!);
  }
}
