import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/chat_api_service.dart';
import 'chat_room_page.dart';
import '../widgets/custom_bottom_nav.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<dynamic> _chatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatList();
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
        title: const Text('Messages', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 3),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatList.isEmpty
          ? const Center(child: Text("No messages yet."))
          : ListView.builder(
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                final chat = _chatList[index];
                final targetId = chat['target_user_id'];
                final targetName = chat['target_user_name'] ?? 'Unknown User';
                final targetImg = chat['target_user_img'];
                final lastMessage = chat['last_message'] ?? '';
                final time = _formatTime(chat['last_message_time'] ?? '');

                // Simple unread indicator logic (Note: relies on last_message being unread AND not sent by us)
                // Currently backend getChatList just returns if the last message is read or not.
                // For perfect read status, it's better logic, but for now we just show it.

                return ListTile(
                  tileColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: (targetImg != null && targetImg.isNotEmpty)
                        ? NetworkImage(targetImg)
                        : null,
                    child: (targetImg == null || targetImg.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        targetName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  onTap: () async {
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
                    // Refresh list when coming back
                    _fetchChatList();
                  },
                );
              },
            ),
    );
  }
}
