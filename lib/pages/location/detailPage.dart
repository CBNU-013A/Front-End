// pages/location/DetailPage.dart
import 'dart:async';
import 'dart:io';
import 'package:final_project/services/location_service.dart';
import 'package:final_project/services/user_service.dart';
import 'package:final_project/widgets/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:final_project/main.dart';
import 'package:final_project/services/like_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:final_project/widgets/BottomNavi.dart';
import 'package:final_project/widgets/detail/AnalysisTab.dart';
import 'package:final_project/widgets/detail/InfoTab.dart';
import 'package:final_project/widgets/detail/ReviewTab.dart';
import 'package:final_project/widgets/detail/summaryTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = Platform.isAndroid
    ? 'http://${dotenv.env['BASE_URL']}:8001'
    : 'http://localhost:8001';

class DetailPage extends StatefulWidget {
  final String placeId;
  final String placeName;

  const DetailPage({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late SharedPreferences prefs;
  String token = ''; //토큰 저장
  String userId = ''; //유저아이디 저장
  String userName = ''; //유저네임 저장

  final likeService = LikeService();
  final _locationSrvice = LocationService();

  Map<String, dynamic> placeData = {};

  bool _isLoading = true;
  bool _isPlaceFound = false;
  Map<String, dynamic>? _matchedPlace;
  late TabController _tabController;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    loadPlace();
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    userName = prefs.getString('userName') ?? '';
    token = prefs.getString('token') ?? '';
  }

  void loadPlace() async {
    try {
      final data = await _locationSrvice.fetchLocation("${widget.placeId}");

      if (data.isNotEmpty) {
        placeData = data;
        setState(() {
          _matchedPlace = placeData;
          _isPlaceFound = true;
          _isLoading = false;
          _tabController = TabController(length: 4, vsync: this);
        });
      } else {
        setState(() {
          _isPlaceFound = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ 장소 불러오기 실패: $e");
      setState(() {
        _isPlaceFound = false;
        _isLoading = false;
      });
    }
  }

  void _handleLikeChanged(bool isNowLiked) {
    setState(() {
      _isLiked = isNowLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.placeName} ',
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
            '${widget.placeName} ',
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
                '${widget.placeName} ',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              floating: true,
              pinned: true,
              backgroundColor: AppColors.lightGreen,
              actions: [
                LikeButton(
                  userId: userId,
                  placeId: widget.placeId,
                  token: token,
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
                      ImageSection(context: context, place: _matchedPlace!),
                      InfoSection(data: _matchedPlace!),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                  child: PreferredSize(
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
                        _tabController.index =
                            index; // Index 변경: 1, 2, 3, 4로 설정
                      });
                    },
                  ),
                ),
              )),
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
                  ReviewsTab(
                    data: _matchedPlace!,
                  ),
                  InfoTab(data: _matchedPlace!)
                ],
              ),
      ),
      bottomNavigationBar: const BottomNavi(),
    );
  }
}

class InfoSection extends StatelessWidget {
  const InfoSection({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
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
                      debugPrint("❌ URL이 비어 있음");
                      return;
                    }
                    Uri? uri;
                    try {
                      uri = Uri.parse(extractedUrl);
                      if (uri.host.isEmpty || !uri.hasScheme) {
                        debugPrint("❌ URI 호스트 또는 스킴 없음: $extractedUrl");
                        return;
                      }
                    } catch (e) {
                      debugPrint("❌ URI 파싱 오류: $e");
                      return;
                    }
                    try {
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
                    style: TextStyle(
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
}

class ImageSection extends StatefulWidget {
  const ImageSection({
    super.key,
    required this.context,
    required this.place,
  });

  final BuildContext context;
  final Map<String, dynamic> place;

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.place['firstimage'] ?? '';
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
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({required this.child});

  final Widget child;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }

  @override
  double get minExtent => child is PreferredSizeWidget
      ? (child as PreferredSizeWidget).preferredSize.height
      : 50;
  @override
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
