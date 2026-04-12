import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_api_service.dart';
import 'chat_room_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> _chatList = [];
  Set<String> _readNotifications = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadNotifications();
    _fetchChatList();
  }

  Future<void> _loadReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _readNotifications = (prefs.getStringList('read_notifications') ?? [])
          .toSet();
    });
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      _readNotifications.add(id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'read_notifications',
      _readNotifications.toList(),
    );
  }

  Future<void> _fetchChatList() async {
    try {
      final list = await ChatApiService.fetchChatList();
      if (mounted) {
        setState(() {
          _chatList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching chat list: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '';
    final dt = DateTime.parse(isoTime).toLocal();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat('hh:mm a').format(dt);
    }
    return DateFormat('MMM dd').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatList.isEmpty
          ? const Center(child: Text("No notifications yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                final chat = _chatList[index];
                final targetId = chat['target_user_id'];
                final targetName = chat['target_user_name'] ?? 'Unknown User';
                final targetImg = chat['target_user_img'];
                final lastMessage = chat['last_message'] ?? '';
                final time = _formatTime(chat['last_message_time'] ?? '');

                // Use a combination of targetId and time as a unique notification identifier
                final String notifId =
                    "${targetId}_${chat['last_message_time']}";
                final bool isUnread = !_readNotifications.contains(notifId);

                return GestureDetector(
                  onTap: () async {
                    _markAsRead(notifId);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          targetUserId: targetId.toString(),
                          targetUserName: targetName,
                          targetUserImage: targetImg,
                        ),
                      ),
                    );
                    _fetchChatList();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUnread
                          ? Colors.blue.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnread
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notification Icon / Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.1),
                          ),
                          child: (targetImg != null && targetImg.isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(
                                    targetImg,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.notifications_active,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "New message from $targetName",
                                      style: TextStyle(
                                        fontWeight: isUnread
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: isUnread
                                          ? Colors.blue
                                          : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Tap to view: \"$lastMessage\"",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
