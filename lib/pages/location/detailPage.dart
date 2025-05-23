// pages/location/detailPage.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'package:final_project/main.dart';
import 'package:final_project/pages/review/summary.dart';
import 'package:final_project/pages/review/writeReviewPage.dart';
import 'package:final_project/services/like_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/widgets/BottomNavi.dart';
import 'package:final_project/widgets/detail/AnalysisTab.dart';
import 'package:final_project/widgets/detail/InfoTab.dart';
import 'package:final_project/widgets/detail/ReviewTab.dart';
import 'package:final_project/widgets/detail/summaryTab.dart';
import 'package:final_project/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../review/reviewPage.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.place});

  final String place;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  final likeService = LikeService();
  String? myReview; // 🔥 Add this at the top of _DetailPageState
  late String placeName;
  late String userId;
  late String userName;

  final List<String> _AnalysisOptions = ['전체', '내 취향'];
  int _currentPage = 0;
  bool _isLiked = false;
  bool _isLoading = true;
  bool _isPlaceFound = false;
  KakaoMapController? _mapController;
  Map<String, dynamic>? _matchedPlace;
  late PageController _pageController;
  int _selectedAnalysisIndex = 0; //
  late TabController _tabController;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제 (메모리 누수 방지)
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPlaceData();

    //WidgetsFlutterBinding.ensureInitialized(); // Flutter 초기화
    //auth : javascript key
    // AuthRepository.initialize(appKey: 'c4e1eb2e4df9471dd1f08410194cfd13');
    // // Kakao SDK 초기화 여부 확인
    // KakaoSdk.init(
    //   nativeAppKey: '2a9e7d21868ff0932e17ad3708dcbe9b',
    //   javaScriptAppKey: 'c4e1eb2e4df9471dd1f08410194cfd13',
    // );

    _pageController = PageController(viewportFraction: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_matchedPlace != null && _matchedPlace!['firstimage'] != null) {
        if (_currentPage < _matchedPlace!['firstimage'].length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; // 마지막 페이지에서 첫 페이지로 이동
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500), // 애니메이션 속도 조절
          curve: Curves.easeInOut,
        );
      }
    });
    _tabController = TabController(length: 4, vsync: this);
  }

  void setMapCenter(Map<String, dynamic> data) {
    if (_mapController != null) {
      _mapController!.setCenter(
        LatLng(
          data['location']['latitude'],
          data['location']['longitude'],
        ),
      );
    } else {
      debugPrint("⚠️ KakaoMapController가 아직 초기화되지 않았습니다.");
    }
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

  void _loadUser() async {
    final userService = UserService();
    final userData = await userService.loadUserData();

    if (userData.isNotEmpty) {
      setState(() {
        userId = userData['userId'] ?? '';
        userName = userData['userName'] ?? '';
      });
    }
  }

  // void _loadLikeStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('jwt_token') ?? '';
  //   await LikeService().isLiked(userId, placeName, token);
  // }

  // Place 정보 가져오기
  Future<void> _loadPlaceData() async {
    try {
      placeName = Uri.encodeComponent((widget.place));
      final response = await http.get(
        Uri.parse('$baseUrl/api/location/$placeName'), // ✅ 서버 API로 요청
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _isPlaceFound = true;
          _matchedPlace = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // ✅ 장소를 찾을 수 없음
        setState(() {
          _isLoading = false;
          _isPlaceFound = false;
        });
      } else {
        throw Exception('Failed to load place data');
      }
    } catch (e) {
      debugPrint("❗ 서버 통신 중 오류 발생: $e");
      setState(() {
        _isLoading = false;
        _isPlaceFound = false;
      });
    }
  }

  Widget _buildImageSection(Map<String, dynamic> place) {
    String imageUrl = place['firstimage'] ?? '';
    if (imageUrl.isEmpty) {
      imageUrl = 'https://via.placeholder.com/300x200.png?text=No+Image';
    }
    return SizedBox(
      height: 250.0,
      width: MediaQuery.of(context).size.width,
      child: Image.network(
        imageUrl,
        fit: BoxFit.fill,
        height: 250.0,
        width: MediaQuery.of(context).size.width,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    String extractHref(String htmlString) {
      final match = RegExp(r'href="([^"]+)"').firstMatch(htmlString);
      return match != null ? match.group(1)! : '';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              spacing: 1,
              runSpacing: 0,
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(6.0)),
                    minimumSize: MaterialStateProperty.all(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data['addr1'] ?? ""));
                    HapticFeedback.mediumImpact();
                    rootScaffoldMessengerKey.currentState!.showSnackBar(
                      SnackBarStyles.info("복사 완료"),
                    );
                  },
                  label: const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: AppColors.mustedBlush,
                  ),
                ),
                Text(
                  '${data['addr1'] ?? '주소 정보 없음'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 1,
              runSpacing: 0,
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(6.0)),
                    minimumSize: MaterialStateProperty.all(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    rootScaffoldMessengerKey.currentState!.showSnackBar(
                      SnackBarStyles.info("전화 연결 기능 만들어야함"),
                    );
                  },
                  label: const Icon(
                    Icons.phone,
                    size: 20,
                    color: AppColors.mustedBlush,
                  ),
                ),
                Text(
                  '${data['tell'] ?? '번호 정보 없음'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              spacing: 1,
              runSpacing: 0,
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(6.0)),
                    minimumSize: MaterialStateProperty.all(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  label: const Icon(
                    Icons.link,
                    size: 20,
                    color: AppColors.mustedBlush,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final rawHtml = data['homepage'] ?? '';
                    final extractedUrl = extractHref(rawHtml);
                    if (extractedUrl.isEmpty) {
                      debugPrint("❌ URL이 비어 있습니다.");
                      return;
                    }
                    try {
                      final uri = Uri.parse(extractedUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        debugPrint('❌ 링크 실행 실패: $extractedUrl');
                      }
                    } catch (e) {
                      debugPrint('❗ URL 파싱 오류: $e');
                    }
                  },
                  child: const Text(
                    '홈페이지로 이동',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTap() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48.0), // ✅ 정확한 높이 지정
      child: Container(
        color: AppColors.lightWhite,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '요약'),
            Tab(text: '분석'),
            Tab(text: '리뷰'),
            Tab(text: '정보'),
          ],
          onTap: (index) {
            setState(() {
              _tabController.index = index; // Index 변경: 1, 2, 3, 4로 설정
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.place} ',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isPlaceFound) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.place} ',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text(
            '해당 장소에 대한 데이터를 찾을 수 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              // 🔥 AppBar도 NestedScrollView 안으로
              expandedHeight: 60,
              title: Text(
                '${widget.place} ',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              floating: true,
              pinned: true,
              backgroundColor: AppColors.lightGreen,

              actions: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: () async {
                    setState(() => _isLiked = !_isLiked);
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('jwt_token') ?? '';
                    bool result = await LikeService()
                        .toggleLike(userId, placeName, token, _isLiked);
                    if (result) {
                      //setState(() => _isLiked = !_isLiked);
                      debugPrint('_isLiked: $_isLiked');
                    }
                  },
                  tooltip: _isLiked ? '즐겨찾기에서 제거' : '즐겨찾기에 추가',
                ),
              ],
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxStyles.backgroundBox(),
                  child: Column(
                    children: [
                      _buildImageSection(_matchedPlace!),
                      _buildInfoSection(_matchedPlace!),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(child: _buildTap()),
            ),
          ];
        },
        body: _matchedPlace == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  SummaryTab(data: {
                    'title': _matchedPlace!['title'],
                    'overview': _matchedPlace!['overview'],
                    'onTabChange': () {
                      setState(() {
                        _tabController.index = 1; // 분석 탭으로 이동
                      });
                    }
                  }),
                  AnalysisTab(data: _matchedPlace!),
                  ReviewsTab(data: _matchedPlace!),
                  InfoTab(data: _matchedPlace!)
                ],
              ),
      ),
      bottomNavigationBar: const BottomNavi(),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({required this.child});

  final Widget child;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }

  double get minExtent => child is PreferredSizeWidget
      ? (child as PreferredSizeWidget).preferredSize.height
      : 50;

  double get maxExtent => child is PreferredSizeWidget
      ? (child as PreferredSizeWidget).preferredSize.height
      : 50;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }
}
