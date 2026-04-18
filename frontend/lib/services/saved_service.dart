import '../config/api_config.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class SavedItem {
  final String id;
  final String title;
  final String date;
  final List<String> tags;
  final String details;
  final String link;
  final String contact;
  final bool isTeam; // To distinguish between Competition and Team
  final Color iconColor;
  final String? imageUrl;
  final String? postType;
  final String? roleNeeded;
  final String? teammatesNeeded;
  final String? requiredSkill;
  final String? posterName;
  final String? posterImageUrl;
  final String? posterId;

  SavedItem({
    required this.id,
    required this.title,
    required this.date,
    required this.tags,
    required this.details,
    required this.link,
    required this.contact,
    this.isTeam = false,
    this.iconColor = Colors.blue,
    this.imageUrl,
    this.postType,
    this.roleNeeded,
    this.teammatesNeeded,
    this.requiredSkill,
    this.posterName,
    this.posterImageUrl,
    this.posterId,
  });
}

class SavedService {
  static final ValueNotifier<List<SavedItem>> savedItems =
      ValueNotifier<List<SavedItem>>([]);

  static String get _baseUrl => ApiConfig.baseUrl;

  // Fetch full list of user's favorited items from DB on app start/login
  static Future<void> loadFavorites(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/favorites/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<SavedItem> items = data.map((card) {
          final List<String> categories = card['tags'] != null
              ? List<String>.from(card['tags'])
              : [];
          final List<String> skillFields = card['fields'] != null
              ? List<String>.from(card['fields'])
              : [];
          final isTeam = card['post_type'] == 'team';

          return SavedItem(
            id: card['id']?.toString() ?? '',
            title: card['name'] ?? 'No Title',
            posterName: card['author_name'] ?? 'Unknown User',
            posterImageUrl: card['author_profile_image'],
            posterId: card['author_id']?.toString(),
            date: card['due_date'] != null
                ? DateTime.parse(
                    card['due_date'].toString(),
                  ).toLocal().toString().substring(0, 10)
                : "No Date",
            tags: [...categories, ...skillFields],
            details: card['details'] ?? 'No details available.',
            link: card['register_link'] ?? '',
            contact: card['contact'] ?? 'No contact info',
            isTeam: isTeam,
            iconColor: isTeam
                ? const Color(0xFFE91E63)
                : const Color(0xFF4A8AF4),
            imageUrl: card['image_path'],
            postType: card['post_type'],
            roleNeeded: card['role_needed'],
            teammatesNeeded: card['teammates_needed']?.toString(),
            requiredSkill: card['required_skill'],
          );
        }).toList();

        savedItems.value = items;
      } else {
        // If the server returns an error code, clear the cache
        savedItems.value = [];
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      // If there is a connection error (Node.js is down), clear the cache so it doesn't show stale data
      savedItems.value = [];
    }
  }

  static Future<void> toggleSave(SavedItem item, String? userId) async {
    // 1. Update UI Instantly (Optimistic update)
    final index = savedItems.value.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      savedItems.value = List.from(savedItems.value)..removeAt(index);
    } else {
      savedItems.value = List.from(savedItems.value)..add(item);
    }

    // 2. Synchronize with Backend
    if (userId != null && userId.isNotEmpty && item.id.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/favorites'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId, 'post_id': item.id}),
        );
      } catch (e) {
        debugPrint('Error toggling favorite on backend: $e');
        // We could revert the UI change on failure, but skipping for simplicity
      }
    }
  }

  static bool isSaved(String id) {
    return savedItems.value.any((i) => i.id == id);
  }
}
