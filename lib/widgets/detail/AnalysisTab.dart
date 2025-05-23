// widgets/detail/AnalysisTab.dart
import 'package:final_project/pages/review/reviewPage.dart';
import 'package:flutter/material.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/pages/review/summary.dart';

class AnalysisTab extends StatefulWidget {
  final Map<String, dynamic> data;

  const AnalysisTab({Key? key, required this.data}) : super(key: key);

  @override
  State<AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<AnalysisTab> {
  int _selectedAnalysisIndex = 0;
  final List<String> _analysisOptions = ['전체', '내 취향'];

  Widget toggleAnalysis() {
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
              decoration: BoxDecoration(
                color: AppColors.deepGrean,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_analysisOptions.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAnalysisIndex = index;
                  });
                  if (index == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("사용자 취향이 없어요 😢")),
                    );
                  }
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 80) / 2,
                  alignment: Alignment.center,
                  child: Text(
                    _analysisOptions[index],
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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: toggleAnalysis(),
          ),
          ReviewWidget(place: widget.data['title']),
        ],
      ),
    );
  }
}
