import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:project_matchupuni/config/api_config.dart';

class ChatApiService {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  static Future<List<dynamic>> fetchChatList() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load chat list');
    }
  }

  static Future<List<dynamic>> fetchMessages(String targetUserId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/chat/$targetUserId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  static Future<void> sendMessage(String receiverId, String text) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'receiverId': receiverId, 'message': text}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  static Future<int> checkUnreadCount() async {
    try {
      final token = await _getToken();
      if (token.isEmpty) return 0;
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/unread'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unread_count'] ?? 0;
      }
    } catch (e) {
      // ignore
    }
    return 0;
  }
}
