import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to Home Page after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/matchup-logo.png',
              width: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              "We're your team!",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
