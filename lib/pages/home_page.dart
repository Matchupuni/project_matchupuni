import 'package:flutter/material.dart';
import '../widgets/side_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/saved_service.dart';
import 'competition_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Current selected category
  List<String> _selectedCategories = ['All'];
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Light grayish blue background
      endDrawer: const SideDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background logo watermark
          Center(
            child: Opacity(
              opacity: 0.5, // Adjusted opacity for better visibility
              child: Transform.scale(
                scale: 1.0, // Scale image larger
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
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          reverseDuration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: child,
                              ),
                            );
                          },
                          child: _isFilterExpanded
                              ? Padding(
                                  key: const ValueKey('expanded_filters'),
                                  padding: const EdgeInsets.only(top: 25.0),
                                  child: _buildCategories(),
                                )
                              : const SizedBox(key: ValueKey('collapsed_filters')),
                        ),
                        const SizedBox(height: 25),
                        _buildCompetitionCard(
                          title: "Startup2025",
                          posterName: "ICT Club",
                          date: "Now - 02/12/2025",
                          tags: [
                            "Business & Strategy",
                            "Design & Creative",
                            "Software & App Development"
                          ],
                          details: "Join the biggest startup competition of the year! Bring your innovative ideas to life and win prizes up to \$10,000. Open to all university students.",
                          link: "bit.ly/startup2025-reg",
                          contact: "startup2025@uni.edu",
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const CustomBottomNav(selectedIndex: 0),
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
              "Welcome",
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
        GestureDetector(
          onTap: () {
            setState(() {
              _isFilterExpanded = !_isFilterExpanded;
            });
          },
          child: Icon(
            Icons.filter_alt,
            size: 26,
            color: _isFilterExpanded ? const Color(0xFF4285F4) : Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDE82), // Light amber/yellow
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search For Find ...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 5),
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.black87),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = [
      'All',
      'Competition',
      'Camp & Workshop',
      'Business & Startup',
      'Tech & AI',
      'Creative & Design',
      'Other',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Quick Filters",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategories = ['All'];
                });
              },
              child: const Text(
                "Reset",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4285F4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0, // Gap between adjacent chips
          runSpacing: 10.0, // Gap between lines
          children: categories.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (cat == 'All') {
                    _selectedCategories = ['All'];
                  } else {
                    // Remove 'All' if it was there
                    _selectedCategories.remove('All');
                    
                    if (isSelected) {
                      _selectedCategories.remove(cat);
                    } else {
                      _selectedCategories.add(cat);
                    }
                    
                    // If everything removed, back to 'All'
                    if (_selectedCategories.isEmpty) {
                      _selectedCategories = ['All'];
                    }
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4285F4)
                      : const Color(0xFFD3DEF5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4285F4).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600, // Keep weight fixed to avoid jump
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompetitionCard({
    required String title,
    required String posterName,
    required String date,
    required List<String> tags,
    required String details,
    required String link,
    required String contact,
  }) {
    final isSaved = SavedService.isSaved(title);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
            // Image Preview at the top with Date Badge
            Stack(
              children: [
                Image.asset(
                  'assets/competition_preview.png',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3246),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        SavedService.toggleSave(SavedItem(
                          title: title,
                          date: date,
                          tags: tags,
                          details: details,
                          link: link,
                          contact: contact,
                          isTeam: false,
                          iconColor: const Color(0xFF4A8AF4),
                        ));
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: const Color(0xFFE91E63),
                        size: 20,
                      ),
                    ),
                  ),
                ],  
              ),
            ),
            // Poster Avatar and Name (Moved below title and styled to match TeamPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.purple[100],
                    child: const Icon(Icons.person, size: 14, color: Colors.purple),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    posterName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // See More Bottom Banner (Synchronized with TeamPage)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompetitionDetailPage(
                      title: title,
                      date: date,
                      tags: tags,
                      details: details,
                      link: link,
                      contact: contact,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF9CBEEB), // Light blue banner theme
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "See more",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4A8AF4), 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}
