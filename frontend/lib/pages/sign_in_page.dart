import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'login_page.dart';
import 'package:project_matchupuni/config/api_config.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static const Color _pink = Color(0xFFE91263);
  static const Color _darkText = Color(0xFF1E232C);
  static const Color _bg = Color(0xFFF7F9FC);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showTopNotification(String message, {Color color = Colors.redAccent}) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopNotificationWidget(
        message: message,
        backgroundColor: color,
        onDismissed: () {
          overlayEntry?.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  Future<void> _handleRegister() async {
    final String user = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String pass = _passwordController.text.trim();
    final String confirm = _confirmController.text.trim();

    if (user.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showTopNotification("Please fill in all fields");
      return;
    }

    if (pass != confirm) {
      _showTopNotification("Password and Confirm password do not match!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String baseUrl = ApiConfig.baseUrl;
      if (!kIsWeb && Platform.isAndroid) {}

      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'full_name': user, 'email': email, 'password': pass}),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _showTopNotification(
            "Registration Successful! Please login.",
            color: Colors.green,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          _showTopNotification(data['error'] ?? "Registration failed");
        }
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification("Network error: $e");
      }
    } finally {
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
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Header
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _darkText,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Hello! ',
                          style: TextStyle(color: _pink),
                        ),
                        TextSpan(text: 'Register to get\nstarted'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Input fields
                  _buildField('Username', _usernameController),
                  const SizedBox(height: 14),
                  _buildField('Email', _emailController),
                  const SizedBox(height: 14),
                  _buildField(
                    'Password',
                    _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    'Confirm password',
                    _confirmController,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),

                  const SizedBox(height: 28),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _handleRegister, // Validation handler
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login Now link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: _darkText, fontSize: 14),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login Now',
                              style: TextStyle(
                                color: _pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable text field
  Widget _buildField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _pink, width: 1.5),
        ),
      ),
    );
  }
}

class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;
  final Color backgroundColor;

  const _TopNotificationWidget({
    Key? key,
    required this.message,
    required this.onDismissed,
    this.backgroundColor = Colors.redAccent,
  }) : super(key: key);

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _showAndHide();
  }

  Future<void> _showAndHide() async {
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      await _controller.reverse();
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.backgroundColor == Colors.green
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
