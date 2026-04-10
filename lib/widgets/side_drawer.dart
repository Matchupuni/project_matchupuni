import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/saved_service.dart';
import '../pages/competition_detail_page.dart';
import '../pages/welcome_page.dart';
import '../pages/edit_profile_page.dart';
import 'package:project_matchupuni/config/api_config.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String _userFullName = "";
  String _userEmail = "";
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userFullName = prefs.getString('user_full_name') ?? 'Guest User';
      _userEmail = prefs.getString('user_email') ?? 'No Email';
      _userId = prefs.getString('user_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: const Color(0xFFFBE8A6), // Yellow background
      child: Column(
        children: [
          _buildTopProfile(context),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F9FC), // Light greyish background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ValueListenableBuilder<List<SavedItem>>(
                valueListenable: SavedService.savedItems,
                builder: (context, savedList, _) {
                  return Column(
                    children: [
                      const SizedBox(height: 25),
                      _buildSavedHeader(savedList.length),
                      const SizedBox(height: 15),
                      Expanded(
                        child: savedList.isEmpty
                            ? const Center(
                                child: Text(
                                  "No saved posts yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                itemCount: savedList.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 15),
                                itemBuilder: (context, index) {
                                  final item = savedList[index];
                                  return _buildSavedCard(context, item: item);
                                },
                              ),
                      ),
                      _buildLogoutButton(context),
                      const SizedBox(height: 35),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProfile(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.pop(); // Close the drawer
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Avatar Placeholder
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEEF6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _userFullName.isNotEmpty ? _userFullName : "Guest User",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _userEmail.isNotEmpty ? _userEmail : "No Email",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD3DEF5), // Light blue base
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Color(0xFFE91E63),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Saved Posts",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFB1C9ED), // Light blue badge
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "$count items",
              style: const TextStyle(
                color: Color(0xFF2C5697), // Darker text color
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, {required SavedItem item}) {
    final bool hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final String imagePath = hasImage ? item.imageUrl!.split(',').first : '';
    final String fullImageUrl = imagePath.startsWith('http')
        ? imagePath
        : '${ApiConfig.baseUrl}$imagePath';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left block acting as image placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: item.iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: hasImage
                ? Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.dashboard,
                      color: Colors.white30,
                      size: 28,
                    ),
                  )
                : const Icon(Icons.dashboard, color: Colors.white30, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2C3246),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.date,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => SavedService.toggleSave(item, _userId),
                child: Container(
                  width: 36, // Standardized size
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.pink[50], // Light pink background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Color(0xFFE91E63), // Primary Pink
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop(); // Close the drawer
                  navigator.push(
                    MaterialPageRoute(
                      builder: (context) => CompetitionDetailPage(
                        title: item.title,
                        date: item.date,
                        tags: item.tags,
                        details: item.details,
                        link: item.link,
                        contact: item.contact,
                        imageUrl: item.imageUrl,
                        posterName: item.posterName,
                        posterImageUrl: item.posterImageUrl,
                        posterId: item.posterId,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 36, // Standardized size matching Bookmark
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue[50], // Light blue background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.visibility, // Better icon for "See more"
                        size: 20,
                        color: Color(0xFF2196F3), // Primary Blue
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "See more",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63), // Pink
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // Safely capture the navigator before popping the drawer
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomePage()),
            (route) => false,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
