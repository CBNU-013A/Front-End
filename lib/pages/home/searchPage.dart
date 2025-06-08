// pages/home/SearchPage.dart
import 'dart:io';
import 'package:final_project/services/location_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:final_project/widgets/search_bar.dart' as custom;
import 'package:final_project/pages/location/detailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/BottomNavi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final userService = UserService();
  final locationService = LocationService();
  String userId = '';
  String userName = '';
  String token = '';
  List<dynamic> allPlaces = [];
  List<dynamic> filteredPlaces = [];
  List<dynamic> recentsearches = [];
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadPrefs();
    loadRecentSearches();
    loadPlaces();
  }

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
      token = prefs.getString('token') ?? '';
    });
  }

  void loadPlaces() async {
    final placeData = await locationService.fetchAllLocations();
    if (placeData.isNotEmpty) {
      setState(() {
        allPlaces = placeData;
      });
    } else {
      debugPrint("모든 장소 정보 없음");
    }
  }

  void loadRecentSearches() async {
    final placeData = await userService.fetchRecentSearch(userId);
    if (placeData.isNotEmpty) {
      setState(() {
        recentsearches = placeData;
      });
    } else {
      ("최근 검색 기록 없음");
    }
  }

  void filterPlaces(String query) {
    if (query.isEmpty) {
      filteredPlaces = [];
      return;
    }
    filteredPlaces = allPlaces
        .where((place) =>
            place['title'] != null &&
            place['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "최근 검색 기록",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    await userService.resetRecentSearch(userId);

                    final recent = await userService.fetchRecentSearch(userId);

                    if (mounted) {
                      setState(() {
                        recentsearches = recent;
                      });
                    }
                  },
                  child: const Text(
                    '모두 삭제',
                    style: TextStyle(
                      color: AppColors.deepGrean,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
            itemCount: recentsearches.length,
            itemBuilder: (context, index) {
              final place = recentsearches[index];
              final title = place['title'] ?? '이름 없는 장소';
              final id = place['_id']?.toString() ?? '';

              return ListTile(
                title: Text(title),
                trailing: IconButton(
                  icon: const Icon(Icons.close_outlined, color: Colors.grey),
                  onPressed: () async {
                    await userService.deleteRecentSearch(userId, id);
                    final recent = await userService.fetchRecentSearch(userId);
                    if (mounted) {
                      setState(() {
                        recentsearches = recent;
                      });
                    }
                  },
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        placeName: title,
                        placeId: id,
                      ),
                    ),
                  );
                  //화면 전환하고 나서 백그라운드로 저장
                  await userService.deleteRecentSearch(
                      userId, place['_id'].toString());
                  await userService.addRecentSearch(userId, place);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: allPlaces.isEmpty
          ? const Center(child: CircularProgressIndicator()) // ✅ 서버 데이터 오기 전
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      // 검색바

                      child: custom.SearchBar(
                          controller: _controller,
                          onChanged: (value) {
                            filterPlaces(value);
                            setState(() {}); // 🔥 검색창 입력 바뀔 때마다 강제 리빌드
                          },
                          onClear: () {
                            setState(() {
                              _controller.clear();
                              filteredPlaces = [];
                            });
                          },
                          onSubmitted: (query) async {
                            if (query.isNotEmpty) {
                              setState(() {
                                _controller.clear();
                                filterPlaces(query);
                              });
                              await userService.addRecentSearch(
                                  userId, filteredPlaces[0]['_id']);
                              final recent =
                                  await userService.fetchRecentSearch(userId);
                              if (mounted) {
                                setState(() {
                                  recentsearches = recent;
                                });
                              }
                              await Future.delayed(
                                  Duration.zero); // Flutter event loop에 양보
                              if (!mounted) return;

                              if (filteredPlaces.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                      placeName: filteredPlaces[0]['title'],
                                      placeId:
                                          filteredPlaces[0]['_id'].toString(),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('해당 장소가 없어요 😢'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          }),
                    ),
                    if (_controller.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            filteredPlaces = [];
                          });
                        },
                        child: Text(
                          '취소',
                          style: TextStyles.mediumTextStyle
                              .copyWith(color: AppColors.deepGrean),
                        ),
                      ),
                  ]),
                  // 검색 내용
                  if (_controller.text.isNotEmpty && filteredPlaces.isNotEmpty)
                    ListView.builder(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPlaces.length,
                      itemBuilder: (context, index) {
                        final place = filteredPlaces[index];
                        return ListTile(
                          title: Text(place['title']),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  placeName: place['title'],
                                  placeId: place['_id'].toString(),
                                ),
                              ),
                            );
                            //화면 전환하고 나서 백그라운드로 저장
                            await userService.deleteRecentSearch(
                                userId, place['_id'].toString());
                            await userService.addRecentSearch(userId, place);
                            //_controller.clear();
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  _buildRecentSearches(),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavi(currentIndex: 2),
    );
  }
}
