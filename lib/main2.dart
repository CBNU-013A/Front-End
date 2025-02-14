// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'place_model.dart';
// import './pages/loginPage.dart';
// import 'dart:convert';
// import 'pages/searchPage.dart';
// import 'package:final_project/setKeyword.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class UserPreferencesPage extends StatefulWidget {
//   const UserPreferencesPage({super.key});

//   @override
//   UserPreferencesPageState createState() => UserPreferencesPageState();
// }

// class UserPreferencesPageState extends State<UserPreferencesPage> {
//   String userName = '';
//   List<String> userPreferences = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData(); // JSON 파일에서 데이터 로드
//   }

//   Future<void> _loadUserData() async {
//     final String jsonString =
//         await rootBundle.loadString('assets/data/member.json');
//     final List<dynamic> jsonData = json.decode(jsonString);

//     // "이름" 데이터 찾기
//     final userData = jsonData.firstWhere(
//       (user) => user['name'] == '이형진',
//       orElse: () => null,
//     );

//     if (userData != null) {
//       setState(() {
//         userName = userData['name'];
//         userPreferences = List<String>.from(userData['keywords']);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Text(
//                   '$userName 님의 관광 취향',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     final updatedKeywords = await Navigator.push<List<String>>(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => KeywordSettingsPage(
//                           initialKeywords: userPreferences,
//                         ),
//                       ),
//                     );

//                     if (updatedKeywords != null) {
//                       setState(() {
//                         userPreferences = updatedKeywords;
//                       });
//                     }
//                   },
//                   child: Row(
//                     children: [
//                       const Text(
//                         '설정',
//                         style: TextStyle(
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Icon(Icons.chevron_right, color: Colors.grey[600]),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             // Pass the userPreferences to Keyword widget
//             Expanded(
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Keyword(keywords: userPreferences),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Keyword extends StatelessWidget {
//   const Keyword({super.key, required this.keywords});

//   final List<String> keywords;

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       direction: Axis.horizontal,
//       alignment: WrapAlignment.start,
//       spacing: 5.0,
//       runSpacing: 10.0,
//       children: keywords
//           .map((keyword) => Container(
//                 padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
//                 decoration: BoxDecoration(
//                   color: const Color.fromRGBO(170, 186, 154, 1),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Text(
//                   keyword,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ))
//           .toList(),
//     );
//   }
// }

// // main.dart
// void main() {
//   runApp(const MyApp());
// }

// // 메인 앱
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   MyAppState createState() => MyAppState();

//   // @override
//   // Widget build(BuildContext context) {
//   //   return MaterialApp(
//   //     debugShowCheckedModeBanner: false,
//   //     theme: ThemeData(
//   //       primarySwatch: Colors.blue,
//   //       fontFamily: 'Pretendard',
//   //       scaffoldBackgroundColor: Colors.white,
//   //     ),
//   //     home: const HomePage(),
//   //   );
//   // }
// }

// class MyAppState extends State<MyApp> {
//   Widget _startScreen = const CircularProgressIndicator(); // 초기 화면 로딩 UI

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString("token"); // 저장된 JWT 토큰 확인

//     if (token != null) {
//       // 로그인 상태라면 HomePage로 이동
//       setState(() {
//         _startScreen = const HomePage();
//       });
//     } else {
//       // 로그인하지 않았다면 LoginPage로 이동
//       setState(() {
//         _startScreen = const LoginPage();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Pretendard',
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: Scaffold(
//         body: Center(
//           child: _startScreen,
//         ),
//       ),
//     );
//   }
// }

// // 홈 페이지

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60.0),
//         child: AppBar(
//           backgroundColor: const Color.fromRGBO(195, 191, 216, 1),
//           title: const Text(
//             '여행지 추천 시스템',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             // 상단 섹션 (검색바 및 카테고리 필터)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: const [
//                     SizedBox(height: 3),
//                     SearchBar(),
//                     SizedBox(height: 3),
//                     SizedBox(
//                       height: 130,
//                       child: UserPreferencesPage(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // 추천 관광지
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     SizedBox(
//                       height: 600, // Explicit height for PlaceLoader
//                       child: PlacePreferencesPage(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 검색바 위젯
// class SearchBar extends StatelessWidget {
//   const SearchBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // 클릭 시 화면 이동
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SearchPage(), // 다음 페이지 연결
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Row(
//           children: [
//             Icon(CupertinoIcons.search, color: Colors.grey),
//             SizedBox(
//               width: 10,
//               height: 35,
//             ),
//             Text(
//               '여행지를 검색하세요',
//               style: TextStyle(color: Colors.grey, fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 카테고리 버튼 위젯
// class CategoryPill extends StatelessWidget {
//   const CategoryPill({super.key, required this.text});

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: ElevatedButton(
//         onPressed: () {}, // 해당 카테고리 필터 액션
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 50, 171, 111),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         child: Text(text, style: const TextStyle(color: Colors.black)),
//       ),
//     );
//   }
// }

// // 장소 카드 위젯
// class PlaceCard extends StatelessWidget {
//   const PlaceCard({super.key, required this.place});

//   final Place place;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: const Color.fromARGB(255, 249, 243, 232),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildImageSection(),
//           _buildContentSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageSection() {
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(
//         top: Radius.circular(10.0),
//       ),
//       child: SizedBox(
//         width: double.infinity,
//         height: 200,
//         child: Image.asset(
//           place.imageUrl,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return const Center(
//               child: Icon(
//                 Icons.broken_image,
//                 color: Colors.grey,
//                 size: 50,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildContentSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             place.name,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             place.address,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             direction: Axis.horizontal,
//             alignment: WrapAlignment.start,
//             spacing: 5.0,
//             children: place.keywords.map((keyword) {
//               return Chip(
//                 label: Text(
//                   keyword,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 backgroundColor: const Color.fromRGBO(170, 186, 154, 1),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PlacePreferencesPage extends StatefulWidget {
//   const PlacePreferencesPage({super.key});

//   @override
//   PlacePreferencesPageState createState() => PlacePreferencesPageState();
// }

// class PlacePreferencesPageState extends State<PlacePreferencesPage> {
//   String userName = '';
//   List<String> userPreferences = [];
//   List<Place> recommendedPlaces = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _loadRecommendedPlaces();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final String jsonString =
//           await rootBundle.loadString('assets/data/member.json');
//       final List<dynamic> jsonData = json.decode(jsonString);

//       final userData = jsonData.firstWhere(
//         (user) => user['name'] == '이형진',
//         orElse: () => null,
//       );

//       if (userData != null) {
//         setState(() {
//           userName = userData['name'];
//           userPreferences = List<String>.from(userData['keywords']);
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading user data: $e');
//     }
//   }

//   Future<void> _loadRecommendedPlaces() async {
//     try {
//       final String jsonString =
//           await rootBundle.loadString('assets/data/inform.json');
//       final List<dynamic> jsonData = json.decode(jsonString);

//       final filteredPlaces = jsonData
//           .where((place) {
//             final placeKeywords = List<String>.from(place['keywords']);
//             return placeKeywords
//                 .any((keyword) => userPreferences.contains(keyword));
//           })
//           .map((place) => Place.fromJson(place))
//           .toList();

//       setState(() {
//         recommendedPlaces = filteredPlaces;
//       });
//     } catch (e) {
//       debugPrint('Error loading places: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             const SizedBox(height: 10),
//             _buildRecommendedPlacesList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Text(
//       '$userName 님의 추천 관광지',
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   Widget _buildRecommendedPlacesList() {
//     if (recommendedPlaces.isEmpty) {
//       return const Expanded(
//         child: Center(
//           child: Text(
//             '추천할 관광지가 없습니다.',
//             style: TextStyle(color: Colors.grey),
//           ),
//         ),
//       );
//     }

//     return SizedBox(
//       height: 420.0, // 원하는 높이 설정
//       width: double.infinity,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal, // 가로 스크롤
//         itemCount: recommendedPlaces.length,
//         itemBuilder: (context, index) {
//           final place = recommendedPlaces[index];
//           return SizedBox(
//             width: 340, // 각 카드의 가로 크기 제한
//             child: PlaceCard(place: place),
//           );
//         },
//       ),
//     );
//   }
// }
