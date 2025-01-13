import 'package:flutter/material.dart';

class RecentSearches extends StatelessWidget {
  final Function(String placeName) onTap;

  const RecentSearches({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<String> searches = ['상당산성', '청남대', '충북대']; // 예제 데이터

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
          ListView.builder(
            shrinkWrap: true,
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final search = searches[index];
              return ListTile(
                title: Text(search),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // 검색 기록 삭제 로직
                  },
                ),
                onTap: () => onTap(search),
              );
            },
          ),
        ],
      ),
    );
  }
}
