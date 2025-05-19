// pages/home/favoritePage.dart
import 'package:flutter/material.dart';
import 'package:final_project/services/favorite_service.dart';
import 'package:final_project/pages/location/detailPage.dart';
import 'package:final_project/styles/text_styles.dart';
import 'package:final_project/widgets/BottomNavi.dart';
import 'package:final_project/widgets/main_app_bar.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final service = FavoriteService();
    final data = await service.getFavorites();
    setState(() {
      favorites = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: '즐겨찾기'),
      body: favorites.isEmpty
          ? const Center(child: Text("즐겨찾기한 장소가 없습니다."))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final place = favorites[index];
                return ListTile(
                  title: Text(place),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(place: place),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: const BottomNavi(),
    );
  }
}
