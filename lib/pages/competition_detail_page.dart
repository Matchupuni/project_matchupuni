import 'package:flutter/material.dart';

class CompetitionDetailPage extends StatelessWidget {
  final String title;
  final String date;
  final List<String> tags;
  final String details;
  final String link;
  final String contact;
  final String? imageUrl;
  final String? postType;
  final String? roleNeeded;
  final String? teammatesNeeded;
  final String? requiredSkill;

  const CompetitionDetailPage({
    super.key,
    required this.title,
    required this.date,
    required this.tags,
    required this.details,
    required this.link,
    required this.contact,
    this.imageUrl,
    this.postType,
    this.roleNeeded,
    this.teammatesNeeded,
    this.requiredSkill,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Background logo watermark
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/matchup-logo.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.75,
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button & Title
                    Row(
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
                              Icons.arrow_back,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
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
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Competition Info Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Placeholder/Header
                          if (imageUrl != null && imageUrl!.isNotEmpty)
                            _ImageCarousel(imageUrls: imageUrl!.split(','))
                          else
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE91E63),
                                    Color(0xFF9CBEEB),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.emoji_events,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tags
                                .map((tag) => _buildTag(tag))
                                .toList(),
                          ),
                          const SizedBox(height: 20),

                          // Date
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFFE91E63),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Due Date: $date",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3246),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (postType == 'team') ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.group,
                                  size: 18,
                                  color: Color(0xFFE91E63),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Teammates Needed: ${teammatesNeeded ?? 'Any'}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3246),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.work,
                                  size: 18,
                                  color: Color(0xFFE91E63),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Role Needed: ${roleNeeded ?? 'Any'}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3246),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (requiredSkill != null &&
                                requiredSkill!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.psychology,
                                    size: 18,
                                    color: Color(0xFFE91E63),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Required Skill: $requiredSkill",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3246),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                          const SizedBox(height: 24),

                          // Description
                          if (details.isNotEmpty &&
                              details != 'No Description') ...[
                            const Text(
                              "About Activity",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3246),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              details,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Contact Info
                          const Text(
                            "Contact",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3246),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            contact,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4A8AF4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Action Button (Register Link)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Link would be used here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91E63),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Register: $link",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'http://localhost:3000${widget.imageUrls[index]}',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFF9CBEEB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 10 : 8,
                height: _currentPage == index ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? const Color(0xFFE91E63)
                      : Colors.grey[400],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
