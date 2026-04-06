import 'package:flutter/material.dart';
import 'login_page.dart';
import 'sign_in_page.dart'; // [ADDED] import for the new Sign-In / Register page

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const Color _pink = Color(0xFFE91263);
  // [CHANGED] bg updated to match home_page/login/sign_in (0xFFF7F9FC)
  static const Color _bgColor = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [


            // ── Main content ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // [CHANGED] was 0.14 — increased top space so logo won't feel too close to the top
                  SizedBox(height: size.height * 0.16),

                  // Logo — large, centred
                  Center(
                    child: Image.asset(
                      'assets/matchup-logo.png',
                      width: size.width * 0.82,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // [CHANGED] was 18 — increased gap between logo and tagline so they don't feel cramped
                  const SizedBox(height: 30),

                  // Subtitle tagline
                  Text(
                    "We're your team !",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(),

                  // ── Login button — filled pink ───────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Sign-in button — white outlined ──────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      // [CHANGED] was empty — now navigates to SignInPage
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign-in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
