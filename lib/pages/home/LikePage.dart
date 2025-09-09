// pages/home/LikePage.dart
import 'package:final_project/services/location_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/services/like_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/styles/text_styles.dart';
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
      backgroundColor: AppColors.lighterGreen,
      extendBodyBehindAppBar: false,
      appBar: const MainAppBar(
        title: '즐겨찾기',
        actions: [],
      ),
      body: Container(
        decoration: BoxStyles.backgroundBox(),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : likedPlaces.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 즐겨찾기한 장소가 없어요',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '마음에 드는 장소를 찾아보세요!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              Text(
                                '${userName}님이 좋아하는 장소',
                                style: AppTextStyles.sectionTitle,
                              ),
                              const SizedBox(height: 16),
                            ]),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16.0,
                              crossAxisSpacing: 16.0,
                              childAspectRatio: 0.65,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final place = likedPlaces[index];
                                return GestureDetector(
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1.0,
                                            child: place['firstimage'] !=
                                                        null &&
                                                    place['firstimage']
                                                        .isNotEmpty
                                                ? Image.network(
                                                    place['firstimage'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(Icons
                                                          .image_not_supported),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey[200],
                                                    child:
                                                        const Icon(Icons.place),
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                place['title'] ?? '제목 없음',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                place['addr1'] ?? '주소 없음',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: likedPlaces.length,
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
      bottomNavigationBar: const BottomNavi(currentIndex: 1),
    );
  }
}
