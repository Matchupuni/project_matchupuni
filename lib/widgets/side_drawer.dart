import 'package:flutter/material.dart';
import '../services/saved_service.dart';
import '../pages/competition_detail_page.dart';
import '../pages/login_page.dart';
import '../pages/welcome_page.dart';
import '../pages/edit_profile_page.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({
    super.key,
  }); // Removed savedPosts property, now using service

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
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfilePage()),
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
              child: const Text(
                "PluemICT033",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "pluem@gmail.com",
                style: TextStyle(color: Colors.grey, fontSize: 13),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left block acting as image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: item.iconColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.dashboard, color: Colors.white30, size: 24),
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
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => SavedService.toggleSave(item),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Color(0xFFE91E63),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompetitionDetailPage(
                        title: item.title,
                        date: item.date,
                        tags: item.tags,
                        details: item.details,
                        link: item.link,
                        contact: item.contact,
                        imageUrl: item.imageUrl,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const Text(
                      "See more",
                      style: TextStyle(fontSize: 9, color: Colors.grey),
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
