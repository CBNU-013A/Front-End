import 'package:final_project/pages/location/DetailPage.dart';
import 'package:final_project/services/like_service.dart';
import 'package:final_project/services/location_service.dart';
import 'package:final_project/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLocationContainer extends StatefulWidget {
  const MyLocationContainer({super.key});

  @override
  State<MyLocationContainer> createState() => _MyLocationContainerState();
}

class _MyLocationContainerState extends State<MyLocationContainer> {
  final likeService = LikeService();
  final locationService = LocationService();
  bool isLoading = true;
  String userName = '';
  String userId = '';
  String token = '';
  late SharedPreferences prefs;
  List<dynamic> likedPlaces = [];
  bool _showDetail = false;
  String? _currentAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentAddress();
  }

  Future<void> _loadCurrentAddress() async {
    try {
      Position position = await _getCurrentLocation();

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        setState(() {
          _currentAddress =
              '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.country}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentAddress = '주소 정보를 찾을 수 없습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❗ 오류 발생: $e");
      setState(() {
        _currentAddress = '위치 정보를 가져올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스 비활성화');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한 거부됨');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한 영구 거부됨');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showDetail = !_showDetail;
                      });
                    },
                    icon: Icon(
                      _showDetail ? Icons.expand_more : Icons.chevron_right,
                      color: AppColors.mainGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '내 위치',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGrean,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(0),
                // decoration: BoxDecoration(
                //   color: AppColors.mainGreen.withOpacity(0.1),
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: TextButton(
                  onPressed: () async {
                    await Geolocator.openAppSettings();
                  },
                  child: const Text(
                    "설정",
                    style: TextStyle(
                      color: AppColors.deepGrean,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showDetail)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      _currentAddress ?? '주소 없음',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.marineBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
            )
        ],
      ),
    );
  }
}
