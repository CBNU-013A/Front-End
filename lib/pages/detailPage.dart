import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'dart:async';
import '../styles/styles.dart';

class DetailPage extends StatefulWidget {
  final String place;

  const DetailPage({super.key, required this.place});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  KakaoMapController? _mapController;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  bool _isLoading = true;
  bool _isPlaceFound = false;
  Map<String, dynamic>? _matchedPlace;

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
    _pageController = PageController(viewportFraction: 0.9);
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
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제 (메모리 누수 방지)
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaceData() async {
    try {
      final String placeName = Uri.encodeComponent(widget.place);
      final response = await http.get(
        Uri.parse('http://localhost:5001/location/$placeName'), // ✅ 서버 API로 요청
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
      appBar: AppBar(
        title: Text(
          'Detail',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(_matchedPlace!),
            _buildKeywordsSection(_matchedPlace!),
            _buildInfoSection(_matchedPlace!),
            _buildMapSection(_matchedPlace!),
            _buildReviewsSection(_matchedPlace!),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Map<String, dynamic> place) {
    List<String> imageUrls = List<String>.from(place['image'] ?? []);
    debugPrint("Image URLs: $imageUrls");
    // 🔹 이미지가 없으면 기본 이미지 추가 (예방)
    if (imageUrls.isEmpty) {
      imageUrls.add(
          'https://via.placeholder.com/300x200.png?text=No+Image'); // Use a valid placeholder image URL
    }
    return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: SizedBox(
            height: 200.0,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
                //scrollDirection: Axis.horizontal,
                controller: _pageController,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 5, left: 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.fill,
                        height: 200.0,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  );
                })));
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data['name'] ?? '이름 없음',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          //const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
                icon: const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Color(0xFF4738D7),
                ),
                onPressed: () {
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
                },
              ),
              //const SizedBox(width: 4), // 아이콘과 텍스트 간격 조정
              Text(
                '${data['address'] ?? '주소 정보 없음'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 0,
          ),
          if (data['tell'] != null)
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                  icon: const Icon(
                    Icons.phone,
                    size: 20,
                    color: Color(0xFF4738D7),
                  ),
                  onPressed: () {},
                ),
                // const Icon(Icons.phone, size: 20, color: Color(0xFF4738D7)),
                // const SizedBox(width: 4), // 아이콘과 텍스트 간격 조정
                Text(
                  '${data['tell'] ?? '주소 정보 없음'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

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
        child: SizedBox(
          height: 200, // ✅ 높이 지정 (필수)
          width: double.infinity, // ✅ 가로는 최대
          child: KakaoMap(
            center: location,
            currentLevel: 6,
            onMapCreated: (KakaoMapController controller) async {
              debugPrint("🗺️ KakaoMap 컨트롤러 초기화 완료!");
              _mapController = controller;
              await Future.delayed(const Duration(seconds: 1));
            },
            markers: [
              Marker(
                markerId: data['id'] ?? "default_id",
                latLng: location, // ✅ latLng 값이 올바르게 설정됨
                infoWindowContent: "위치",
              )
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint("❗ 위치 변환 중 오류 발생: $e");
      return const Center(child: Text("위치 정보를 불러오는 중 오류 발생"));
    }
  }

  Widget _buildKeywordsSection(Map<String, dynamic> data) {
    final List<dynamic> keywords = data['keywords'] ?? [];
    if (keywords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('관련 키워드가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    debugPrint('Keywords: ${data['keywords']}');

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
      child: SingleChildScrollView(
        //controller: _pageController,
        scrollDirection: Axis.horizontal,
        child: Row(
            children: keywords.map((keyword) {
          final String text = keyword.toString();
          return Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Chip(
              labelPadding: const EdgeInsets.only(left: 8, right: 8),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.lightTaube),
              ),
              backgroundColor: AppColors.lightTaube,

              //padding: AppStyles.keywordChipPadding.copyWith(left: 8, right: 8),
              label: Text(text,
                  style: AppStyles.keywordChipTextStyle
                      .copyWith(fontSize: 14)), // ✅ `text` 반환
            ),
          );
        }).toList()),
      ),
    );
  }

  Widget _buildReviewsSection(Map<String, dynamic> data) {
    final List<dynamic> reviews = data['review'] ?? [];
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('관련 리뷰가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    debugPrint('✅ Review 불러오기 성공');

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: reviews.map((review) {
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review ?? '알 수 없음',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
