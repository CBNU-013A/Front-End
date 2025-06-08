// pages/home/LikePage.dart
import 'package:final_project/services/location_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/services/like_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/widgets/BottomNavi.dart';
import 'package:final_project/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/pages/location/DetailPage.dart';

class Likepage extends StatefulWidget {
  const Likepage({super.key});

  @override
  State<Likepage> createState() => _LikepageState();
}

class _LikepageState extends State<Likepage> {
  late SharedPreferences prefs;
  final likeService = LikeService();
  final locationService = LocationService();
  String userId = '';
  String userName = '';
  String token = '';
  List<dynamic> likedPlaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
      token = prefs.getString('token') ?? '';
    });
    await loadLikedPlaces();
  }

  Future<void> loadLikedPlaces() async {
    setState(() {
      isLoading = true;
    });

    final idList = await likeService.loadUserLikePlaces(userId, token);
    final detailedPlaces = await locationService.fetchLocationsByIds(
      idList.map<String>((item) => item['_id'] as String).toList(),
    );
    setState(() {
      likedPlaces = detailedPlaces;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightWhite,
      extendBodyBehindAppBar: false,
      appBar: const MainAppBar(
        title: '즐겨찾기',
        actions: [],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedPlaces.isEmpty
              ? const Center(child: Text('즐겨찾기한 장소가 없습니다.'))
              : ListView.builder(
                  itemCount: likedPlaces.length,
                  itemBuilder: (context, index) {
                    final place = likedPlaces[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        leading: place['firstimage'] != null &&
                                place['firstimage'].isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  place['firstimage'],
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey[300],
                                    child:
                                        const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey[300],
                                child: const Icon(Icons.place),
                              ),
                        title: Text(place['title'] ?? '제목 없음'),
                        subtitle: Text(place['addr1'] ?? '주소 없음'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                placeName: place['title'] ?? '제목 없음',
                                placeId: place['_id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const BottomNavi(currentIndex: 1),
    );
  }
}
