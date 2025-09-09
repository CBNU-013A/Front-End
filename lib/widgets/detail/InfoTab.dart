// widgets/detail/InfoTab.dart
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:final_project/styles/styles.dart';

class InfoTab extends StatefulWidget {
  final Map<String, dynamic> data;

  const InfoTab({Key? key, required this.data}) : super(key: key);

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  KakaoMapController? _mapController;

  @override
  void initState() {
    super.initState();
    KakaoSdk.init(
      nativeAppKey: '2a9e7d21868ff0932e17ad3708dcbe9b',
      javaScriptAppKey: 'c4e1eb2e4df9471dd1f08410194cfd13',
    );
    AuthRepository.initialize(appKey: 'c4e1eb2e4df9471dd1f08410194cfd13');
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

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    // mapx, mapy가 있으면 location을 생성
    if (data['location'] == null &&
        data['mapx'] != null &&
        data['mapy'] != null) {
      data['location'] = {
        'latitude': (data['mapy'] is String)
            ? double.tryParse(data['mapy']) ?? 0.0
            : data['mapy'],
        'longitude': (data['mapx'] is String)
            ? double.tryParse(data['mapx']) ?? 0.0
            : data['mapx'],
      };
    }

    if (data['location'] == null ||
        data['location']['latitude'] == null ||
        data['location']['longitude'] == null) {
      return const Center(child: Text("위치 정보 없음"));
    }

    debugPrint("📍 위치 데이터: ${data['location']}");

    try {
      double latitude = (data['location']['latitude'] is String)
          ? double.parse(data['location']['latitude'])
          : data['location']['latitude'];

      double longitude = (data['location']['longitude'] is String)
          ? double.parse(data['location']['longitude'])
          : data['location']['longitude'];

      LatLng location = LatLng(latitude, longitude);

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              
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
                      latLng: location,
                      infoWindowContent: data['title'],
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
}
