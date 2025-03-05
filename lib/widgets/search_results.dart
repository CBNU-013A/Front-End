import 'package:flutter/material.dart';
import 'package:final_project/pages/detailPage.dart';

class SearchResults extends StatelessWidget {
  final List<dynamic> places;
  final Function(Map<String, dynamic>) onTap;
  final String query;

  const SearchResults({
    super.key,
    required this.places,
    required this.onTap,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '검색 결과가 없습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final double itemHeight = 50.0; // 각 아이템의 고정 높이
    final double maxHeight =
        MediaQuery.of(context).size.height * 0.4; // 최대 높이 제한
    final double calculatedHeight =
        (places.length * itemHeight).clamp(0, maxHeight);

    return SizedBox(
      height: calculatedHeight,
      child: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return GestureDetector(
            onTap: () => onTap(place),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 243, 213),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   (place['keywords'] as List<dynamic>).join(', '),
                  //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
}
