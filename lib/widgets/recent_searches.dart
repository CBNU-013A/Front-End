import 'package:flutter/material.dart';
import 'package:final_project/pages/detailPage.dart';

class RecentSearches extends StatelessWidget {
  final Function(String placeName) onTap; // 항목 클릭 시 실행되는 콜백
  final List<String> searches; // 검색 기록 데이터

  const RecentSearches({
    super.key,
    required this.onTap,
    required this.searches,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 검색 기록',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          searches.isEmpty
              ? const Center(
                  child: Text(
                    '최근 검색 기록이 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true, // 내부 리스트뷰의 높이를 자식 요소에 맞게 설정
                  physics: const NeverScrollableScrollPhysics(), // 외부 스크롤 허용
                  itemCount: searches.length,
                  itemBuilder: (context, index) {
                    final placeName = searches[index];

                    return ListTile(
                      title: Text(placeName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // 검색 기록 삭제 로직

                          onTap(placeName); // 삭제 콜백 호출
                        },
                      ),
                      onTap: () {
                        // 클릭 시 DetailPage로 장소 이름만 전달
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(place: placeName),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
