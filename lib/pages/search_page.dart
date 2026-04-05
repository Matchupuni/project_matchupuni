import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/saved_service.dart';
import '../services/search_history_service.dart';
import 'competition_detail_page.dart';
import 'report_page.dart';

class SearchPage extends StatefulWidget {
  /// 'activity' for Home page searches, 'team' for Team page searches
  final String searchType;

  const SearchPage({super.key, required this.searchType});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _searchQuery = '';
  String _sortBy = 'Newest';
  List<String> _selectedCategories = ['All'];
  bool _isFilterExpanded = false;

  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    // Auto-focus the search field when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadRecentSearches() async {
    final searches =
        await SearchHistoryService.getRecentSearches(widget.searchType);
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isTeam => widget.searchType == 'team';

  List<String> get _categories {
    if (_isTeam) {
      return [
        'All',
        'Software & App Development',
        'Data Science & AI',
        'Cybersecurity',
        'Business & Strategy',
        'Hardware & Engineering',
        'Design & Creative',
      ];
    } else {
      return [
        'All',
        'Competition',
        'Camp & Workshop',
        'Business & Startup',
        'Tech & AI',
        'Creative & Design',
        'Other',
      ];
    }
  }

  Future<void> _fetchResults() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasSearched = true;
      });
    }

    try {
      Map<String, dynamic> queryParams = {
        'post_type': _isTeam ? 'team' : 'activity',
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      if (!_selectedCategories.contains('All') &&
          _selectedCategories.isNotEmpty) {
        if (_isTeam) {
          queryParams['field'] = _selectedCategories;
        } else {
          queryParams['tag'] = _selectedCategories;
        }
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
            _results = json.decode(response.body);
            // Sorting
            if (_sortBy == 'Newest') {
              _results.sort(
                (a, b) =>
                    (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
              );
            } else {
              _results.sort(
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
        debugPrint('Failed to load results: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching results: $e');
    }
  }

  void _performSearch([String? queryOverride]) {
    final query = queryOverride ?? _searchController.text.trim();
    _searchController.text = query;
    setState(() {
      _searchQuery = query;
    });
    // Save to SQLite history
    SearchHistoryService.addSearch(query, widget.searchType).then((_) {
      _loadRecentSearches();
    });
    _fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFFFFDE82);
    final Color searchTextColor = Colors.black87;
    final Color searchHintColor = Colors.grey[600]!;
    final Color searchIconColor = Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: Back + Search input
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Color(0xFF2C3246),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter icon
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
                  // Search input
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              style: TextStyle(color: searchTextColor),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _performSearch(),
                              decoration: InputDecoration(
                                hintText: _isTeam
                                    ? 'Search skill, project, topic ...'
                                    : 'Search For Find ...',
                                hintStyle: TextStyle(
                                  color: searchHintColor,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.only(bottom: 5),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _results = [];
                                  _hasSearched = false;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.black54,
                                size: 20,
                              ),
                            ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _performSearch,
                            child: Icon(
                              Icons.search,
                              color: searchIconColor,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Filter Section
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
                  ? Container(
                      key: const ValueKey('expanded_filters'),
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _buildCategories(),
                    )
                  : const SizedBox(key: ValueKey('collapsed_filters')),
            ),

            // Sort options
            if (_hasSearched)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _buildSortOptions(),
              ),

            // Search results header
            if (_searchQuery.isNotEmpty && _hasSearched)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Search Results for "$_searchQuery"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3246),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // Results list
            Expanded(
              child: _buildResultsBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      // Show recent searches or empty prompt
      return _buildRecentSearches();
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        if (_isTeam) {
          return _buildTeamResultCard(item);
        } else {
          return _buildActivityResultCard(item);
        }
      },
    );
  }

  // ─── Recent Searches Section ───
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      // No history — show empty prompt
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _isTeam
                  ? 'Search for teammates, skills, or projects'
                  : 'Search for competitions or activities',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  await SearchHistoryService.clearHistory(widget.searchType);
                  _loadRecentSearches();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // List of recent searches
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final query = _recentSearches[index];
              return Dismissible(
                key: Key('recent_$query'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await SearchHistoryService.deleteSearch(
                      query, widget.searchType);
                  _loadRecentSearches();
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_outline,
                      color: Colors.red[400], size: 22),
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0),
                    leading: Icon(Icons.history,
                        size: 20, color: Colors.grey[400]),
                    title: Text(
                      query,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.north_west,
                        size: 16, color: Colors.grey[400]),
                    onTap: () {
                      _performSearch(query);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Activity Card (matches HomePage style) ───
  Widget _buildActivityResultCard(Map<String, dynamic> card) {
    final String postId = card['id']?.toString() ?? '';
    final String title = card['name'] ?? 'No Title';
    final String posterName = 'ICT Club';
    final String date = card['due_date'] != null
        ? DateTime.parse(card['due_date'].toString())
            .toLocal()
            .toString()
            .substring(0, 10)
        : 'No Date';
    final List<String> categories =
        card['tags'] != null ? List<String>.from(card['tags']) : [];
    final List<String> skillFields =
        card['fields'] != null ? List<String>.from(card['fields']) : [];
    final String details = card['details'] ?? 'No details available.';
    final String link = card['register_link'] ?? '';
    final String contact = card['contact'] ?? 'No contact info';
    final String? imageUrl = card['image_path'];

    final isSaved = SavedService.isSaved(title);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
            // Image
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
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.white),
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
            // Title + Actions
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
                          color: Colors.red[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.report_problem_outlined,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Poster
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.purple[100],
                    child: const Icon(Icons.person,
                        size: 14, color: Colors.purple),
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
            // Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...categories
                      .map((tag) => _buildTag(tag, const Color(0xFF4A8AF4))),
                  ...skillFields
                      .map((field) => _buildTag(field, const Color(0xFF4CAF50))),
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
            // See more
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
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Team Card (matches TeamPage style) ───
  Widget _buildTeamResultCard(Map<String, dynamic> post) {
    final String postId = post['id']?.toString() ?? '';
    final String title = post['name'] ?? 'No Title';
    final String posterName = post['author_name'] ?? 'Unknown User';
    final String postedDate = post['due_date'] != null
        ? DateTime.parse(post['due_date'].toString())
            .toLocal()
            .toString()
            .substring(0, 10)
        : 'No Date';
    final String personCount =
        '${post['teammates_needed'] ?? "?"} People';
    final String roleCategory = post['role_needed'] ?? 'Any Role';
    final String roleDescription = post['details'] ?? 'No Description';
    final String contact = post['contact'] ?? 'No contact info';
    final String? imageUrl = post['image_path'];
    final String link = post['register_link'] ?? 'N/A';
    final String requiredSkill =
        post['required_skill']?.toString() ?? 'Any Skill';

    final List<String> allTags = [];
    if (post['tags'] != null) {
      allTags.addAll(List<String>.from(post['tags']));
    }
    if (post['fields'] != null) {
      allTags.addAll(List<String>.from(post['fields']));
    }

    final isSaved = SavedService.isSaved(title);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
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
                            image:
                                AssetImage('assets/competition_preview.png'),
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
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.white),
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
            // Title + Actions
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        SavedService.toggleSave(
                          SavedItem(
                            title: title,
                            date: postedDate,
                            tags: allTags,
                            details: roleDescription,
                            link: link,
                            contact: contact,
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
                            builder: (context) => ReportPage(
                                postId: postId, postTitle: title),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.report_problem_outlined,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Poster
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.purple[100],
                    child: const Icon(Icons.person,
                        size: 14, color: Colors.purple),
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
                children: allTags
                    .map((tag) => _buildTag(tag, const Color(0xFF4A8AF4)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Role & Teammates
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 16, color: Color(0xFFE91E63)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Required Skill: $requiredSkill",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.group,
                          size: 16, color: Color(0xFFE91E63)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Teammates Needed: $personCount",
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
            const SizedBox(height: 12),
            // See more
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompetitionDetailPage(
                      title: title,
                      date: postedDate,
                      tags: allTags,
                      details: roleDescription,
                      link: link,
                      contact: contact,
                      imageUrl: imageUrl,
                      postType: 'team',
                      roleNeeded: roleCategory,
                      teammatesNeeded: personCount,
                      requiredSkill: requiredSkill,
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
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 14),
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

  Widget _buildCategories() {
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
                _fetchResults();
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
          children: _categories.map((cat) {
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
                _fetchResults();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4285F4)
                      : const Color(0xFFD3DEF5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4285F4)
                                .withValues(alpha: 0.3),
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
                });
                _fetchResults();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
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
                      const Icon(Icons.check,
                          color: Colors.white, size: 14),
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
                });
                _fetchResults();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
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
                      const Icon(Icons.check,
                          color: Colors.white, size: 14),
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
}
