import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/chat_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomPage extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String? targetUserImage;

  const ChatRoomPage({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserImage,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadUser();
    await _loadMessages();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('user_id');
    if (mounted) setState(() {});
  }

  Future<void> _loadMessages() async {
    if (currentUserId == null) {
      await _loadUser();
    }
    try {
      final messages = await ChatApiService.fetchMessages(widget.targetUserId);
      if (mounted) {
        setState(() {
          _messages = messages.map((m) {
            final isMe = m['sender_id'].toString() == currentUserId.toString();
            return {
              'text': m['message'],
              'isMe': isMe,
              'time': DateFormat(
                'hh:mm a',
              ).format(DateTime.parse(m['created_at']).toLocal()),
            };
          }).toList();
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': DateFormat('hh:mm a').format(DateTime.now()),
      });
    });
    _scrollToBottom();

    try {
      await ChatApiService.sendMessage(widget.targetUserId, text);
      // Optional: re-fetch to ensure sync with server
      await _loadMessages();
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 65, // Increased height for user zone
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24, // Increased size
              backgroundImage:
                  widget.targetUserImage != null &&
                      widget.targetUserImage!.isNotEmpty
                  ? NetworkImage(widget.targetUserImage!)
                  : null,
              child:
                  widget.targetUserImage == null ||
                      widget.targetUserImage!.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ) // Increased icon size
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.targetUserName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18, // Increased font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message['isMe'];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFE91E63) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                        bottomRight: isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['time'],
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black45,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFFE91E63,
                      ), // Pink color matching the app theme
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
