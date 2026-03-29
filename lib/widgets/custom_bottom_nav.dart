import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/post_page.dart';
import '../pages/team_page.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNav({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget page;
    if (index == 0) {
      page = const HomePage();
    } else if (index == 1) {
      page = const PostPage();
    } else {
      page = const TeamPage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            top: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, 0, Icons.home, "Home"),
              _buildNavItem(context, 1, Icons.add, "Post"),
              _buildNavItem(context, 2, Icons.pie_chart_outline, "Team"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          // Subtle elegant shadow
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ), // Safe transparency
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4A8AF4) : Colors.black87,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF4A8AF4),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
