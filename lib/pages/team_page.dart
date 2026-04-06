import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/side_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/saved_service.dart';
import 'competition_detail_page.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // Sort state
  String _sortBy = 'Newest';

  // Category filter state
  List<String> _selectedCategories = ['All'];
  bool _isFilterExpanded = false;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _teamPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeamPosts();
  }

  Future<void> _fetchTeamPosts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      Map<String, dynamic> queryParams = {'post_type': 'team'};

      if (!_selectedCategories.contains('All') &&
          _selectedCategories.isNotEmpty) {
        queryParams['tag'] = _selectedCategories;
      }

      final uri = Uri(
        scheme: 'http',
        host: 'localhost',
        port: 3000,
        path: '/posts',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _teamPosts = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                    padding: const EdgeInsets.fromLTRB(20.0, 45.0, 20.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          reverseDuration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
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
                              : const SizedBox(
                                  key: ValueKey('collapsed_filters'),
                                ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 25),
                          Text(
                            "Search Results for \"$_searchQuery\"",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3246),
                            ),
                          ),
                        ],
                        const SizedBox(height: 25),
                        _buildSortOptions(),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_teamPosts.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No team posts found.'),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: _teamPosts.map((post) {
                                final List<String> categories =
                                    post['fields'] != null
                                    ? List<String>.from(post['fields'])
                                    : [];
                                final List<String> allTags = [];
                                if (post['tags'] != null) {
                                  allTags.addAll(
                                    List<String>.from(post['tags']),
                                  );
                                }
                                allTags.addAll(categories);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: _buildTeamCard(
                                    title: post['name'] ?? 'No Title',
                                    posterName:
                                        post['contact'] ?? 'Unknown User',
                                    postedDate: post['due_date'] != null
                                        ? DateTime.parse(
                                            post['due_date'].toString(),
                                          ).toLocal().toString().substring(
                                            0,
                                            16,
                                          )
                                        : "No Date",
                                    personCount:
                                        '${post['teammates_needed'] ?? "?"} People',
                                    roleCategory:
                                        post['role_needed'] ?? 'Any Role',
                                    tags: allTags,
                                    roleDescription:
                                        post['details'] ?? 'No Description',
                                    imageUrl: post['image_path'],
                                  ),
                                );
                              }).toList(),
                            ),
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
            color: _isFilterExpanded
                ? const Color(0xFF4285F4)
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63), // Pink/Red
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
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
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchQuery = _searchController.text.trim();
                    });
                  },
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
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
      'Software & App Development',
      'Data Science & AI',
      'Cybersecurity',
      'Business & Strategy',
      'Hardware & Engineering',
      'Design & Creative',
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
                _fetchTeamPosts();
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
          spacing: 8.0,
          runSpacing: 10.0,
          children: categories.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (cat == 'All') {
                    _selectedCategories = ['All'];
                  } else {
                    _selectedCategories.remove('All');
                    if (isSelected) {
                      _selectedCategories.remove(cat);
                    } else {
                      _selectedCategories.add(cat);
                    }
                    if (_selectedCategories.isEmpty) {
                      _selectedCategories = ['All'];
                    }
                  }
                });
                _fetchTeamPosts();
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
                    fontWeight: FontWeight.w600,
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

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sort by",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _sortBy = 'Newest');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _sortBy == 'Newest'
                      ? const Color(0xFFE91E63)
                      : const Color(0xFFD3DEF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      "Newest",
                      style: TextStyle(
                        color: _sortBy == 'Newest'
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (_sortBy == 'Newest') ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: Colors.white, size: 14),
                    ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _sortBy == 'Oldest'
                      ? const Color(0xFFE91E63)
                      : const Color(0xFFD3DEF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      "Oldest",
                      style: TextStyle(
                        color: _sortBy == 'Oldest'
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (_sortBy == 'Oldest') ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: Colors.white, size: 14),
                    ],
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
    String? imageUrl,
  }) {
    final isSaved = SavedService.isSaved(title);

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
          // Image Preview
          Stack(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  'http://localhost:3000$imageUrl',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        image: DecorationImage(
                          image: AssetImage('assets/competition_preview.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    image: DecorationImage(
                      image: AssetImage('assets/competition_preview.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Date Badge (Dark Semi-transparent from HomePage style)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        postedDate,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                // Favorite Button (Moved here)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      SavedService.toggleSave(
                        SavedItem(
                          title: title,
                          date: postedDate,
                          tags: tags,
                          details: roleDescription,
                          link: "N/A",
                          contact: "Member contact info",
                          isTeam: true,
                          iconColor: const Color(0xFFE91E63),
                          imageUrl: imageUrl,
                        ),
                      );
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
                      color: isSaved
                          ? const Color(0xFFE91E63)
                          : const Color(0xFFE91E63),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.purple[100],
                  child: const Icon(
                    Icons.person,
                    size: 14,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  posterName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) => _buildTag(tag)).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Role Description (Moved to bottom)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Role Needed : $roleDescription",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // See More Bottom Banner
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompetitionDetailPage(
                    title: title,
                    date: postedDate,
                    tags: tags,
                    details: roleDescription,
                    link: "N/A",
                    contact: "Member contact info",
                    imageUrl: imageUrl,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF9CBEEB), // Light blue banner
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
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4A8AF4), // Blue tag color from home_page.dart
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
