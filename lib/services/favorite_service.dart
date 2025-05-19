// services/favorite_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('favoritePlaces');
    return raw ?? [];
  }

  Future<void> addFavorite(String placeName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList('favoritePlaces') ?? [];
    if (!current.contains(placeName)) {
      current.add(placeName);
      await prefs.setStringList('favoritePlaces', current);
    }
  }

  Future<void> removeFavorite(String placeName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList('favoritePlaces') ?? [];
    current.remove(placeName);
    await prefs.setStringList('favoritePlaces', current);
  }
}
