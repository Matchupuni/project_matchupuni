import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/saved_service.dart';
import 'edit_post_page.dart';
import 'package:project_matchupuni/config/api_config.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  bool _isActivitySelected = true;
  List<dynamic> _cards = [];
  bool _isLoading = true;

  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchCards();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id');
    });
  }

  Future<void> _fetchCards() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/posts');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _cards = json.decode(response.body);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 80, // Fixed width to balance the title
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Color(0xFF2C3246),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              "My Posts",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(
                              width: 80, // Fixed width to balance the title
                              child: _isSelectionMode
                                  ? TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isSelectionMode = false;
                                          _selectedIds.clear();
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(44, 44),
                                        alignment: Alignment.centerRight,
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Color(0xFF4A8AF4),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.centerRight,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Color(0xFF333333),
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isSelectionMode = true;
                                        });
                                      },
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildToggleButtons(),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          ..._buildFilteredCards(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                if (_isSelectionMode && _selectedIds.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: _buildDeleteActionBar(),
                  ),
              ],
            ),
          ),
          const CustomBottomNav(selectedIndex: 1), // Keeps the bottom bar
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFD3DEF5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isActivitySelected = true),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        "Activity",
                        style: TextStyle(
                          color: _isActivitySelected
                              ? Colors.white
                              : Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isActivitySelected = false),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        "Find Teammates",
                        style: TextStyle(
                          color: !_isActivitySelected
                              ? Colors.white
                              : Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: _isActivitySelected
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4A8AF4), // Blue active state
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    _isActivitySelected ? "Activity" : "Find Teammates",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredCards() {
    final filteredCards = _cards.where((card) {
      if (card['author_id'] != _userId) return false;

      final postType = card['post_type'] as String? ?? 'activity';
      if (_isActivitySelected) {
        return postType !=
            'team'; // This properly handles 'activity' and legacy defaults
      } else {
        return postType == 'team';
      }
    }).toList();

    if (filteredCards.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No posts found for this category.'),
        ),
      ];
    }

    return filteredCards.map((card) {
      final List<String> categories = card['tags'] != null
          ? List<String>.from(card['tags'])
          : [];
      final List<String> skillFields = card['fields'] != null
          ? List<String>.from(card['fields'])
          : [];

      final String safeId = card['id'] ?? '';
      final String safeTitle = card['name'] ?? 'No Title';
      final String safeDate = card['due_date'] != null
          ? DateTime.parse(
              card['due_date'].toString(),
            ).toLocal().toString().substring(0, 10)
          : "No Date";
      final String safeLink = card['register_link'] ?? '';
      final String safeContact = card['contact'] ?? 'No contact info';
      final String safeDetails = card['details'] ?? 'No details available.';

      if (_isActivitySelected) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: _buildCompetitionCard(
            id: safeId,
            title: safeTitle,
            posterName: "You",
            date: safeDate,
            categories: categories,
            skillFields: skillFields, // Unused in card, but kept for signature
            details: safeDetails,
            link: safeLink,
            contact: safeContact,
            fullCardData: card,
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: _buildTeamCard(
            id: safeId,
            title: safeTitle,
            posterName: "You",
            postedDate: safeDate,
            personCount: '${card['teammates_needed'] ?? "?"} People',
            roleCategory: card['role_needed'] ?? 'Any Role',
            tags: skillFields.isNotEmpty ? skillFields : categories,
            roleDescription: safeDetails,
            contact: safeContact,
            imageUrl: card['image_path'],
            link: safeLink,
            requiredSkill: card['required_skill']?.toString() ?? 'Any Skill',
            fullCardData: card,
          ),
        );
      }
    }).toList();
  }

  Widget _buildCompetitionCard({
    required String id,
    required String title,
    required String posterName,
    required String date,
    required List<String> categories,
    required List<String> skillFields,
    required String details,
    required String link,
    required String contact,
    required Map<String, dynamic> fullCardData,
  }) {
    final isSaved = SavedService.isSaved(id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _isSelectionMode
            ? () {
                setState(() {
                  if (_selectedIds.contains(id)) {
                    _selectedIds.remove(id);
                  } else {
                    _selectedIds.add(id);
                  }
                });
              }
            : null,
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
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: _isSelectionMode && _selectedIds.contains(id)
                ? Border.all(color: const Color(0xFFE91E63), width: 2)
                : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Preview at the top with Date Badge
                  Stack(
                    children: [
                      fullCardData['image_path'] != null &&
                              fullCardData['image_path'].toString().isNotEmpty
                          ? Image.network(
                              '${ApiConfig.baseUrl}${fullCardData['image_path'].toString().split(',').first}',
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
                      // Small Status Badge to indicate it's your post
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Active Post",
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
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
                        if (!_isSelectionMode)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                SavedService.toggleSave(
                                  SavedItem(
                                    id: id,
                                    title: title,
                                    date: date,
                                    tags: [...categories, ...skillFields],
                                    details: details,
                                    link: link,
                                    contact: contact,
                                    isTeam: false,
                                    iconColor: const Color(0xFF4A8AF4),
                                    imageUrl: fullCardData['image_path'],
                                  ),
                                  _userId,
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
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: const Color(0xFFE91E63),
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Poster Avatar and Name
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
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(0xFFE91E63),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                details.isNotEmpty
                                    ? details
                                    : "No details available.",
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
                  // Bottom Banner (Edit or Selection overlay)
                  if (!_isSelectionMode)
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditPostPage(cardData: fullCardData),
                          ),
                        );
                        if (result == true) {
                          _fetchCards();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "Edit Post",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedIds.contains(id)
                            ? const Color(0xFFE91E63)
                            : Colors.grey[300],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedIds.contains(id)
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedIds.contains(id)
                                ? "Selected"
                                : "Select Post",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard({
    required String id,
    required String title,
    required String posterName,
    required String postedDate,
    required String personCount,
    required String roleCategory,
    required List<String> tags,
    required String roleDescription,
    required String contact,
    String? imageUrl,
    required String link,
    required String requiredSkill,
    required Map<String, dynamic> fullCardData,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _isSelectionMode
            ? () {
                setState(() {
                  if (_selectedIds.contains(id)) {
                    _selectedIds.remove(id);
                  } else {
                    _selectedIds.add(id);
                  }
                });
              }
            : null,
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
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: _isSelectionMode && _selectedIds.contains(id)
                ? Border.all(color: const Color(0xFFE91E63), width: 2)
                : null,
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
                      '${ApiConfig.baseUrl}${imageUrl.split(',').first}',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F0FE),
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/competition_preview.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        image: DecorationImage(
                          image: AssetImage('assets/competition_preview.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  // Date Badge
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
                  // Active Post Badge
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Color(0xFF4CAF50),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Active Post",
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
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
              if (tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags
                        .map((tag) => _buildTag(tag, const Color(0xFF4A8AF4)))
                        .toList(),
                  ),
                ),
              if (tags.isNotEmpty) const SizedBox(height: 12),

              // Role and Teammates with Icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align to top for multi-line support
                      children: [
                        const Icon(
                          Icons
                              .psychology, // Changed from star to psychology to match competition_detail
                          size: 16,
                          color: Color(0xFFE91E63),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Required Skill: $requiredSkill",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 13,
                              height: 1.4, // Line height for multi-line string
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align to top for multi-line support
                      children: [
                        const Icon(
                          Icons
                              .group, // Changed group icon style setup to top aligned
                          size: 16,
                          color: Color(0xFFE91E63),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Teammates Needed: $personCount",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bottom Banner (Edit or Selection overlay)
              if (!_isSelectionMode)
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPostPage(cardData: fullCardData),
                      ),
                    );
                    if (result == true) {
                      _fetchCards();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(color: Color(0xFFE91E63)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Edit Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedIds.contains(id)
                        ? const Color(0xFFE91E63)
                        : Colors.grey[300],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedIds.contains(id)
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedIds.contains(id) ? "Selected" : "Select Post",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteActionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Selected ${_selectedIds.length} items",
            style: const TextStyle(
              color: Color(0xFF2C3246),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          ElevatedButton(
            onPressed: _handleBulkDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Delete Selected",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBulkDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever,
                  color: Color(0xFFE91E63),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Are you sure?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3246),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You are about to delete ${_selectedIds.length} posts. This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('auth_token') ?? '';

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/posts/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"ids": _selectedIds.toList()}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showCustomSnackBar(
            message: 'Posts deleted successfully!',
            isError: false,
          );
          _selectedIds.clear();
          _isSelectionMode = false;
          _fetchCards();
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showCustomSnackBar(
            message: 'Failed to delete posts: ${response.statusCode}',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showCustomSnackBar(
          message: 'Error connecting to server: $e',
          isError: true,
        );
      }
    }
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

  void _showCustomSnackBar({required String message, required bool isError}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -30 * (1 - value)), // Slide down from the top
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isError
                          ? const Color(0xFFE91E63)
                          : const Color(0xFF4A8AF4),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isError
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the snackbar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
