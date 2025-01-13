// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class DetailPage extends StatelessWidget {
//   final Map<String, dynamic> place;

//   const DetailPage({super.key, required this.place});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(place['name']),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Place Details
//             Text(
//               'Name: ${place['name']}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text('Address: ${place['address'] ?? 'No address available'}'),
//             const SizedBox(height: 8),
//             Text('Keywords: ${place['keywords'].join(', ')}'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RecentSearches extends StatefulWidget {
//   const RecentSearches({super.key, required this.onTap});

//   final Function(String placeName)
//       onTap; // Callback for when an item is clicked

//   @override
//   _RecentSearchesState createState() => _RecentSearchesState();
// }

// class _RecentSearchesState extends State<RecentSearches> {
//   final List<String> _recentSearches = []; // Stores recent searches

//   @override
//   void initState() {
//     super.initState();
//     _loadRecentSearches(); // Load data from DB
//   }

//   Future<void> _loadRecentSearches() async {
//     // Replace this with your database fetch logic
//     final dbSearches = await fetchRecentSearchesFromDB();
//     setState(() {
//       _recentSearches.addAll(dbSearches);
//     });
//   }

//   Future<void> _deleteSearch(String placeName) async {
//     // Remove the item from the database
//     await removeSearchFromDB(placeName);
//     setState(() {
//       _recentSearches.remove(placeName);
//     });
//   }

//   Future<void> _addSearch(String placeName) async {
//     if (!_recentSearches.contains(placeName)) {
//       // Add the item to the database
//       await saveSearchToDB(placeName);
//       setState(() {
//         _recentSearches.insert(0, placeName); // Add to the top of the list
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           '최근 검색 기록',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         _recentSearches.isEmpty
//             ? const Center(
//                 child: Text(
//                   '검색 기록이 없습니다.',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               )
//             : ListView.builder(
//                 shrinkWrap: true, // Ensures it doesn't take infinite height
//                 itemCount: _recentSearches.length,
//                 itemBuilder: (context, index) {
//                   final placeName = _recentSearches[index];
//                   return ListTile(
//                     title: Text(placeName),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _deleteSearch(placeName),
//                     ),
//                     onTap: () => widget.onTap(placeName),
//                   );
//                 },
//               ),
//       ],
//     );
//   }
// }
