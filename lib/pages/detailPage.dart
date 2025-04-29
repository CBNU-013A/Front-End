// pages/detailPage.dart
import 'dart:convert';
import 'package:final_project/main.dart';
import 'package:final_project/pages/writeReviewPage.dart';
import 'package:final_project/widgets/TabBar.dart';
import 'package:final_project/widgets/summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'dart:async';
import '../styles/styles.dart';
import '../pages/reviewPage.dart';
import '../widgets/BottomNavi.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.place});

  final String place;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;

  bool _isLoading = true;
  bool _isPlaceFound = false;
  KakaoMapController? _mapController;
  Map<String, dynamic>? _matchedPlace;
  late PageController _pageController;
  late TabController _tabController;

  Timer? _timer;

  int _selectedAnalysisIndex = 0; //
  final List<String> _AnalysisOptions = ['전체', '내 취향'];

  String? myReview; // 🔥 Add this at the top of _DetailPageState

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제 (메모리 누수 방지)
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Flutter 초기화 필수
    //auth : javascript key
    AuthRepository.initialize(appKey: 'c4e1eb2e4df9471dd1f08410194cfd13');
    // Kakao SDK 초기화 여부 확인
    KakaoSdk.init(
      nativeAppKey: '2a9e7d21868ff0932e17ad3708dcbe9b',
      javaScriptAppKey: 'c4e1eb2e4df9471dd1f08410194cfd13',
    );

    debugPrint("✅ KakaoSdk 초기화 상태: ${KakaoSdk.origin}");
    _loadPlaceData();
    _pageController = PageController(viewportFraction: 1.0);
    // 3초마다 자동으로 다음 페이지 이동
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_matchedPlace != null && _matchedPlace!['image'] != null) {
        if (_currentPage < _matchedPlace!['image'].length - 1) {
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
    // _tabController.addListener(() {
    //   if (_tabController.indexIsChanging) {
    //   debugPrint("Tab changed to: ${_tabController.index}");
    //   }
    // });
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

  Future<void> _loadPlaceData() async {
    try {
      final String placeName = Uri.encodeComponent(widget.place);
      final response = await http.get(
        Uri.parse(
            'http://localhost:8001/api/location/$placeName'), // ✅ 서버 API로 요청
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
    List<String> imageUrls = List<String>.from(place['image'] ?? []);
    //debugPrint("Image URLs: $imageUrls");
    // 🔹 이미지가 없으면 기본 이미지 추가 (예방)
    if (imageUrls.isEmpty) {
      imageUrls = ['https://via.placeholder.com/300x200.png?text=No+Image'];
    }
    return SizedBox(
      height: 250.0,
      width: MediaQuery.of(context).size.width,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(0),
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.fill,
              height: 200.0,
              width: MediaQuery.of(context).size.width,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameSection(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Text(
              data['name'] ?? '이름 없음',
              style: const TextStyle(
                  letterSpacing: 0.8,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ]),
          Text('방문자 리뷰 ${data['review']?.length ?? 0}개',
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          //const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Clipboard.setData(
                          ClipboardData(text: data['address'] ?? ""));
                      HapticFeedback.mediumImpact();
                      rootScaffoldMessengerKey.currentState!.showSnackBar(
                        SnackBarStyles.info("복사 완료"),
                      );
                    },
                    label: const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColors.mustedBlush,
                    )),
                Text(
                  '${data['address'] ?? '주소 정보 없음'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                // IconButton(
                //   onPressed: () {
                //     Clipboard.setData(
                //         ClipboardData(text: data['address'] ?? ""));
                //     HapticFeedback.mediumImpact();
                //     rootScaffoldMessengerKey.currentState!.showSnackBar(
                //       SnackBarStyles.info("복사 완료"),
                //     );
                //   },
                //   icon: const Icon(Icons.copy),
                //   iconSize: 14,
                //   alignment: const Alignment(0, 0),
                // ),
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
                    )),
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
                    onPressed: () {
                      rootScaffoldMessengerKey.currentState!.showSnackBar(
                        SnackBarStyles.info("링크 이동"),
                      );
                    },
                    label: const Icon(
                      Icons.link,
                      size: 20,
                      color: AppColors.mustedBlush,
                    )),
                Text(
                  '${data['web'] ?? '웹 사이트 정보 없음'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //분석탭으로 이동
  Widget _buildGoReview(Map<String, dynamic> data) {
    debugPrint("분석 탭 이동");
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: toggleAnalysis(),
            ),
            ReviewWidget(
              place: data['name'],
            ),
          ]),
        ));
  }

  //정보탭으로 이동
  Widget _buildMapSection(Map<String, dynamic> data) {
    // 1. location이 null인지 확인 (에러 방지)
    if (data['location'] == null) {
      return const Center(child: Text("위치 정보 없음"));
    }

    debugPrint("📍 위치 데이터: ${data['location']}");

    if (data['location']['latitude'] == null ||
        data['location']['longitude'] == null) {
      return const Center(child: Text("위도 또는 경도 정보 없음"));
    }

    // 2. 위도, 경도 값 변환 (문자열일 경우 대비)
    try {
      double latitude = (data['location']['latitude'] is String)
          ? double.parse(data['location']['latitude'])
          : data['location']['latitude'];

      double longitude = (data['location']['longitude'] is String)
          ? double.parse(data['location']['longitude'])
          : data['location']['longitude'];

      // ✅ 수정: 변환된 값을 사용하여 LatLng 객체 생성
      LatLng location = LatLng(latitude, longitude);

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SizedBox(
              height: 220, // ✅ 높이 지정 (필수)
              width: double.infinity, // ✅ 가로는 최대
              child: KakaoMap(
                center: location,
                currentLevel: 4,
                onMapCreated: (KakaoMapController controller) async {
                  debugPrint("🗺️ KakaoMap 컨트롤러 초기화 완료!");
                  _mapController = controller;
                  await controller.addMarker(markers: [
                    Marker(
                      width: 24,
                      height: 30,
                      markerId: data['id']?.toString() ?? 'default_id',
                      latLng: location, // ✅ latLng 값이 올바르게 설정됨
                      infoWindowContent: data['name'],
                    ),
                  ]);
                },
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                elevation: 2,
                onPressed: () => setMapCenter(data),
                child: const Icon(Icons.refresh, color: Colors.black),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("❗ 위치 변환 중 오류 발생: $e");
      return const Center(child: Text("위치 정보를 불러오는 중 오류 발생"));
    }
  }

  //리뷰탭으로 이동
  Widget _buildReviewsSection(Map<String, dynamic> data) {
    final List<dynamic> reviews = data['review'] ?? [];

    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('관련 리뷰가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    debugPrint('✅ Review 불러오기 성공');
    //debugPrint("내가 쓴 리뷰 ", myReview);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightWhite,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(
                      "내가 쓴 리뷰",
                      style: TextStyles.mediumTextStyle
                        .copyWith(color: Colors.black),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      ),
                     child: (myReview == null || myReview!.isEmpty)
                         ? TextButton(
                             onPressed: () async {
                               final result = await Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => WriteReviewPage(
                                     initialText: "", // Empty for new review
                                     place: widget.place,
                                   ),
                                 ),
                               );
                               if (result != null && result is String) {
                                 setState(() {
                                   myReview = result;
                                 });
                               }
                             },
                             child: const Text(
                               "리뷰 작성하기",
                               style: TextStyle(color: AppColors.deepGrean),
                             ),
                           )
                         : TextButton(
                             onPressed: () async {
                               final result = await Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => WriteReviewPage(
                                     initialText: myReview!,
                                     place: widget.place,
                                   ),
                                 ),
                               );
                               if (result != null && result is String) {
                                 setState(() {
                                   myReview = result;
                                 });
                               }
                             },
                             child: Text(
                               myReview!,
                               style: const TextStyle(fontSize: 14, color: AppColors.deepGrean),
                             ),
                           ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightWhite,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: reviews.map((review) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review ?? '리뷰 내용 없음',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ]),
      ),
    );
  }

  //요약탭으로 이동
  Widget _buildSummarySection(Map<String, dynamic> data) {
    debugPrint("⭐️_buildSummarySection");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightWhite,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "지피티 한줄 요약",
                    style: TextStyles.mediumTextStyle
                        .copyWith(color: Colors.black),
                  ),
                  const Text("여기에 요약글을 적을게용"),
                ]),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightWhite,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "분석 요약",
                    style: TextStyles.mediumTextStyle
                        .copyWith(color: Colors.black),
                  ),
                  toggleAnalysis(),
                  SummaryWidget(
                    place: data['name'],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: SizedBox(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tabController.index = 1; // 리뷰 탭으로 변경
                      });
                    },
                    child: Text(
                      textAlign: TextAlign.right,
                      "자세히 보기",
                      style: TextStyles.mediumTextStyle
                          .copyWith(color: Colors.grey),
                    ),
                  ),
                ]),
          ),
          //_buildKeywordsSection(_matchedPlace!),
        ],
      ),
    );
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            '${widget.place}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              title: Text(
                '${widget.place}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              floating: true,
              pinned: true,
              backgroundColor: AppColors.lightGreen,
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
                  _buildSummarySection(_matchedPlace!),
                  _buildGoReview(_matchedPlace!),
                  _buildReviewsSection(_matchedPlace!),
                  _buildMapSection(_matchedPlace!),
                ],
              ),
      ),
      bottomNavigationBar: const BottomNavi(),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverTabBarDelegate({required this.child});

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

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
