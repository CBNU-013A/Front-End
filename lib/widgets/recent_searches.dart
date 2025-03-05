import 'package:flutter/material.dart';
import 'package:final_project/pages/detailPage.dart';
import 'package:final_project/pages/searchPage.dart';

class RecentSearches extends StatefulWidget {
  final Function(String placeName) onTap; // 항목 클릭 시 실행되는 콜백
  final Function(String placeName) onSearches; // 최근 검색어 추가 콜백
  final List<String> searches; // 검색 기록 데이터

  const RecentSearches({
    super.key,
    required this.onTap,
    required this.searches,
    required this.onSearches,
  });

  @override
  State<RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  void addSearch(String placeName) {
    widget.searches.insert(0, placeName); // 최근 검색어를 맨 앞에 추가
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // const Text(
          //   '최근 검색 기록',
          //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 8),
          widget.searches.isEmpty
              ? const Center(
                  child: Text(
                    ' ',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true, // 내부 리스트뷰의 높이를 자식 요소에 맞게 설정

                  physics: const NeverScrollableScrollPhysics(), // 외부 스크롤 허용
                  itemCount: widget.searches.length,
                  itemBuilder: (context, index) {
                    final placeName = widget.searches[index];

                    return ListTile(
                      title: Text(placeName),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_outlined,
                            color: Colors.grey),
                        onPressed: () {
                          widget.onTap(placeName); // 삭제 콜백 호출
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
                        widget.onSearches(placeName); // 최근 검색어 추가
                        addSearch(placeName); // 최근 검색어 추가
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
