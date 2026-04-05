import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/side_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/saved_service.dart';
import 'competition_detail_page.dart';
import 'report_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sort state
  String _sortBy = 'Newest';

  // Category filter state
  List<String> _selectedCategories = ['All'];
  bool _isFilterExpanded = false;



  List<dynamic> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      Map<String, dynamic> queryParams = {'post_type': 'activity'};

      if (!_selectedCategories.contains('All') &&
          _selectedCategories.isNotEmpty) {
        // using 'tag' for home_page activity categories
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
            _cards = json.decode(response.body);
            // Sorting
            if (_sortBy == 'Newest') {
              _cards.sort(
                (a, b) =>
                    (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
              );
            } else {
              _cards.sort(
                (a, b) =>
                    (a['created_at'] ?? '').compareTo(b['created_at'] ?? ''),
              );
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        debugPrint('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching cards: $e');
    }
  }

  @override
  void dispose() {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 10),
                        // Top Section: Greeting, Profile, Theme Toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildSearchBar(),
                        ),
                        const SizedBox(height: 10),

                        // Expandable Filter Section
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
                                  padding: const EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    bottom: 10.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [_buildCategories()],
                                  ),
                                )
                              : const SizedBox(
                                  key: ValueKey('collapsed_filters'),
                                  width: double.infinity,
                                ),
                        ),

                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildSortOptions(),
                        ),
                        const SizedBox(height: 15),

                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_cards.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No competitions found.'),
                            ),
                          )
                        else
                          ..._cards.map((card) {
                            final List<String> categories = card['tags'] != null
                                ? List<String>.from(card['tags'])
                                : [];
                            final List<String> skillFields =
                                card['fields'] != null
                                ? List<String>.from(card['fields'])
                                : [];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: _buildCompetitionCard(
                                postId: card['id']?.toString() ?? '',
                                title: card['name'] ?? 'No Title',
                                posterName: "ICT Club",
                                date: card['due_date'] != null
                                    ? DateTime.parse(
                                        card['due_date'].toString(),
                                      ).toLocal().toString().substring(0, 10)
                                    : "No Date",
                                categories: categories,
                                skillFields: skillFields,
                                details:
                                    card['details'] ?? 'No details available.',
                                link: card['register_link'] ?? '',
                                contact: card['contact'] ?? 'No contact info',
                                imageUrl: card['image_path'],
                              ),
                            );
                          }),
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
            color: _isFilterExpanded
                ? const Color(0xFF4285F4)
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SearchPage(searchType: 'activity'),
                ),
              );
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDE82),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search For Find ...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.search,
                    color: Colors.black87,
                    size: 26,
                  ),
                ],
              ),
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
                _fetchCards();
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
                _fetchCards();
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
                            color: const Color(
                              0xFF4285F4,
                            ).withValues(alpha: 0.3),
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
                setState(() {
                  _sortBy = 'Newest';
                  _fetchCards();
                });
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
                setState(() {
                  _sortBy = 'Oldest';
                  _fetchCards();
                });
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

  Widget _buildCompetitionCard({
    required String postId,
    required String title,
    required String posterName,
    required String date,
    required List<String> categories,
    required List<String> skillFields,
    required String details,
    required String link,
    required String contact,
    String? imageUrl,
  }) {
    final isSaved = SavedService.isSaved(title);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        'http://localhost:3000${imageUrl.split(',').first}',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/competition_preview.png',
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/competition_preview.png',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
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
                        SavedService.toggleSave(
                          SavedItem(
                            title: title,
                            date: date,
                            tags: [...categories, ...skillFields],
                            details: details,
                            link: link,
                            contact: contact,
                            isTeam: false,
                            iconColor: const Color(0xFF4A8AF4),
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
                        color: const Color(0xFFE91E63),
                        size: 20,
                      ),
                    ),
                  ),
                  if (postId.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReportPage(postId: postId, postTitle: title),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              Colors.red[50], // Soft red background for warning
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.report_problem_outlined,
                          color: Colors.red[400], // Distinct red color
                          size: 20,
                        ),
                      ),
                    ),
                  ],
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Categories and Skill Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...categories.map(
                    (tag) => _buildTag(tag, const Color(0xFF4A8AF4)),
                  ), // Blue for Categories
                  ...skillFields.map(
                    (field) => _buildTag(field, const Color(0xFF4CAF50)),
                  ), // Green for Skill Fields
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Details Preview (to match TeamPage height footprint)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFFE91E63)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          details.isNotEmpty ? details : "No details available.",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12), // Spacer below details

            // See More Bottom Banner (Synchronized with TeamPage)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompetitionDetailPage(
                      title: title,
                      date: date,
                      tags: [...categories, ...skillFields],
                      details: details,
                      link: link,
                      contact: contact,
                      imageUrl: imageUrl,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE91E63),
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
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
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
