// widgets/detail/SummaryTab.dart
import 'package:final_project/pages/review/summary.dart';
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SummaryTab extends StatefulWidget {
  const SummaryTab({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  _SummaryTabState createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  final List<String> _AnalysisOptions = ['전체', '내 취향'];
  int _selectedAnalysisIndex = 0;
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  Container toggleAnalysis() {
    return Container(
      height: 35,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
        color: TextFiledStyles.fillColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _selectedAnalysisIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              width: (MediaQuery.of(context).size.width - 80) / 2,
              height: 38,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              // margin: const EdgeInsets.symmetric(
              //     vertical: 5, horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.deepGrean,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_AnalysisOptions.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAnalysisIndex = index;
                  });
                  if (index == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("사용자 취향이 없어요 😢"),
                      ),
                    );
                  }
                },
                child: Container(
                  width:
                      (MediaQuery.of(context).size.width - 80) / 2, // 버튼 크기 통일
                  height: 38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6), // 🔥 텍스트 주변 여백
                  child: Text(
                    _AnalysisOptions[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedAnalysisIndex == index
                          ? Colors.white
                          : AppColors.deepGrean,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightWhite,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "장소 정보",
                    style: TextStyles.mediumTextStyle
                        .copyWith(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.lightWhite,
                          content: SingleChildScrollView(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              (widget.data['overview'] ?? ' ')
                                .replaceAll('\n', '\n\n'),
                              style: const TextStyle(
                              color: Colors.black87,
                              letterSpacing: 1,
                              height: 1.6, // 문단간 간격 조정
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.data['overview'] ?? '요약 없음',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if ((widget.data['overview'] ?? '')
                            .toString()
                            .isNotEmpty)
                          const Text(
                            "더보기",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                      ],
                    ),
                  ),
                ]),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightWhite,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "분석 요약",
                    style: TextStyles.mediumTextStyle
                        .copyWith(color: Colors.black),
                  ),
                  toggleAnalysis(),
                  SummaryWidget(
                    place: widget.data['title'] is String
                        ? widget.data['title']
                        : '',
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: SizedBox(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.data['onTabChange'] != null &&
                          widget.data['onTabChange'] is Function) {
                        widget.data['onTabChange']();
                      } else {
                        debugPrint("자세히 보기 클릭됨 - 탭 전환 콜백이 없습니다.");
                      }
                    },
                    child: Text(
                      textAlign: TextAlign.right,
                      "자세히 보기",
                      style: TextStyles.mediumTextStyle
                          .copyWith(color: Colors.grey),
                    ),
                  ),
                ]),
          ),
          //_buildKeywordsSection(_matchedPlace!),
        ],
      ),
    );
  }
}
