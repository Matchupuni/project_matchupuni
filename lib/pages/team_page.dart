import 'package:flutter/material.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_bottom_nav.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // Sort state
  String _sortBy = 'Newest';

  // State for saved posts
  List<String> savedTeams = [];

  void toggleSave(String title) {
    setState(() {
      if (savedTeams.contains(title)) {
        savedTeams.remove(title);
      } else {
        savedTeams.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Light grayish blue background
      endDrawer: const SideDrawer(savedPosts: []),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background logo watermark
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Transform.scale(
                scale: 1.0,
                child: Image.asset(
                  'assets/matchup-logo.png',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 25),
                        _buildSortOptions(),
                        const SizedBox(height: 20),
                        _buildTeamCard(
                          title: "RobotICT2026",
                          posterName: "PluemICT033",
                          postedDate: "01/02/2026",
                          personCount: "1 Person",
                          roleCategory: "IT , Engineer",
                          tags: ["JAVA", "AI"],
                          roleDescription: "IT , Engineer or if you can build robot!",
                        ),
                        const SizedBox(height: 20),
                        _buildTeamCard(
                          title: "Makeweb2026",
                          posterName: "CheerICT019",
                          postedDate: "30/01/2026",
                          personCount: "2 Person",
                          roleCategory: "UX/UI , Support react",
                          tags: ["Figma", "React"],
                          roleDescription: "hi cheer find team for winner on Makeweb2026",
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const CustomBottomNav(selectedIndex: 2), // Index for Team page
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome'",
              style: TextStyle(
                color: Color(0xFFE91E63), // Pink/Red
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "PluemICT033",
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "Let's find your dream team !",
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Text(
                "EN|TH",
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(width: 10),
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: const Icon(Icons.format_list_bulleted, size: 26),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        const Icon(
          Icons.filter_alt,
          size: 32,
          color: Color(0xFF1E293B), // Dark grey/black
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63), // Pink/Red
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
               children: [
                 Expanded(
                   child: TextField(
                     style: const TextStyle(color: Colors.white),
                     decoration: InputDecoration(
                       hintText: 'Search skill, project, topic ...',
                       hintStyle: TextStyle(
                         color: Colors.white.withOpacity(0.9),
                         fontSize: 15,
                       ),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.only(bottom: 5),
                     ),
                   ),
                 ),
                 const Icon(Icons.search, color: Colors.white, size: 26),
               ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sort by",
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _sortBy = 'Newest');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: _sortBy == 'Newest' ? const Color(0xFFE91E63) : const Color(0xFFD3DEF5),
                    borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      "Newest",
                      style: TextStyle(
                        color: _sortBy == 'Newest' ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (_sortBy == 'Newest') ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: Colors.white, size: 16),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() => _sortBy = 'Oldest');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _sortBy == 'Oldest' ? const Color(0xFFE91E63) : const Color(0xFFD3DEF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                     Text(
                      "Oldest",
                      style: TextStyle(
                        color: _sortBy == 'Oldest' ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (_sortBy == 'Oldest') ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: Colors.white, size: 16),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamCard({
    required String title,
    required String posterName,
    required String postedDate,
    required String personCount,
    required String roleCategory,
    required List<String> tags,
    required String roleDescription,
  }) {
    final isSaved = savedTeams.contains(title);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3246),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => toggleSave(title),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? const Color(0xFF2C3246) : Colors.grey[600], 
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.purple[100],
                  child: const Icon(Icons.person, size: 16, color: Colors.purple),
                ),
                const SizedBox(width: 8),
                Text(
                  posterName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Posted : $postedDate",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Details Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.grey[500]!),
                const SizedBox(width: 6),
                Text(
                  personCount,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 1, height: 16, color: Colors.grey[300]),
                const SizedBox(width: 12),
                Icon(Icons.cases_outlined, size: 18, color: Colors.grey[500]!),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    roleCategory,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => _buildTag(tag)).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Role Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Role Needed : $roleDescription",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Contact Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF9CBEEB), 
            ),
            child: Row(
              children: [
                const Text(
                  "Contact:",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 26),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.photo_camera, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4A8AF4), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
