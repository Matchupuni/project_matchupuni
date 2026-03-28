import 'package:flutter/material.dart';

class SavedItem {
  final String title;
  final String date;
  final List<String> tags;
  final String details;
  final String link;
  final String contact;
  final bool isTeam; // To distinguish between Competition and Team
  final Color iconColor;
  final String? imageUrl;

  SavedItem({
    required this.title,
    required this.date,
    required this.tags,
    required this.details,
    required this.link,
    required this.contact,
    this.isTeam = false,
    this.iconColor = Colors.blue,
    this.imageUrl,
  });
}

class SavedService {
  static final ValueNotifier<List<SavedItem>> savedItems =
      ValueNotifier<List<SavedItem>>([]);

  static void toggleSave(SavedItem item) {
    final index = savedItems.value.indexWhere((i) => i.title == item.title);
    if (index != -1) {
      savedItems.value = List.from(savedItems.value)..removeAt(index);
    } else {
      savedItems.value = List.from(savedItems.value)..add(item);
    }
  }

  static bool isSaved(String title) {
    return savedItems.value.any((i) => i.title == title);
  }
}
