import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_matchupuni/config/api_config.dart';
import 'welcome_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id');
      _usernameController.text = prefs.getString('user_full_name') ?? '';
      _emailController.text = prefs.getString('user_email') ?? '';
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showChangeNameDialog() {
    final _nameDialogController = TextEditingController(
      text: _usernameController.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Change Name"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter your new full name.",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameDialogController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91263),
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          final newName = _nameDialogController.text.trim();

                          if (newName.isEmpty) {
                            _showCustomSnackBar(
                              message: "Name cannot be empty",
                              isError: true,
                            );
                            return;
                          }

                          if (newName == _usernameController.text) {
                            Navigator.pop(context);
                            return;
                          }

                          if (_userId == null) return;

                          setDialogState(() => isDialogLoading = true);

                          try {
                            String baseUrl = ApiConfig.baseUrl;
                            if (!kIsWeb && Platform.isAndroid) {}

                            final response = await http.put(
                              Uri.parse("$baseUrl/users/$_userId/profile"),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "full_name": newName,
                                "email": _emailController.text,
                              }),
                            );

                            if (response.statusCode == 200) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString("user_full_name", newName);

                              if (mounted) {
                                setState(() {
                                  _usernameController.text = newName;
                                });
                                Navigator.pop(context);
                                _showCustomSnackBar(
                                  message: "Name updated successfully",
                                  isError: false,
                                );
                              }
                            } else {
                              String errorMessage =
                                  "Failed to update name (Error ${response.statusCode})";
                              try {
                                final data = jsonDecode(response.body);
                                if (data["error"] != null)
                                  errorMessage = data["error"];
                              } catch (_) {}
                              if (mounted)
                                _showCustomSnackBar(
                                  message: errorMessage,
                                  isError: true,
                                );
                            }
                          } catch (e) {
                            if (mounted)
                              _showCustomSnackBar(
                                message: "Network error: $e",
                                isError: true,
                              );
                          } finally {
                            if (mounted)
                              setDialogState(() => isDialogLoading = false);
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeEmailDialog() {
    final _newEmailController = TextEditingController();
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Change Email'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'To change your email address, please enter your new email and confirm with your current password.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'New Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91263),
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          final newEmail = _newEmailController.text.trim();
                          final pass = _passwordController.text;

                          if (newEmail.isEmpty || pass.isEmpty) {
                            _showCustomSnackBar(
                              message: 'Please fill all fields',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() => isDialogLoading = true);

                          try {
                            String baseUrl = ApiConfig.baseUrl;
                            if (!kIsWeb && Platform.isAndroid) {}

                            final response = await http.put(
                              Uri.parse('$baseUrl/users/$_userId/profile'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'full_name': _usernameController.text.trim(),
                                'email': newEmail,
                                'password': pass,
                              }),
                            );

                            if (response.statusCode == 200) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('user_email', newEmail);

                              if (mounted) {
                                setState(() {
                                  _emailController.text =
                                      newEmail; // Update UI immediately
                                });
                                Navigator.pop(context); // Close dialog
                                _showCustomSnackBar(
                                  message: 'Email updated successfully',
                                  isError: false,
                                );
                              }
                            } else {
                              String errorMessage =
                                  'Failed to update email (Error ${response.statusCode})';
                              try {
                                final data = jsonDecode(response.body);
                                if (data['error'] != null) {
                                  errorMessage = data['error'];
                                }
                              } catch (_) {}

                              if (mounted) {
                                _showCustomSnackBar(
                                  message: errorMessage,
                                  isError: true,
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              _showCustomSnackBar(
                                message: 'Network error: $e',
                                isError: true,
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => isDialogLoading = false);
                            }
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Change',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final _oldPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Old Password',
                    ),
                  ),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91263),
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          final oldPass = _oldPasswordController.text;
                          final newPass = _newPasswordController.text;
                          final confirmPass = _confirmPasswordController.text;

                          if (oldPass.isEmpty ||
                              newPass.isEmpty ||
                              confirmPass.isEmpty) {
                            _showCustomSnackBar(
                              message: 'Please fill all fields',
                              isError: true,
                            );
                            return;
                          }

                          if (newPass != confirmPass) {
                            _showCustomSnackBar(
                              message: 'New passwords do not match',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() => isDialogLoading = true);

                          try {
                            String baseUrl = ApiConfig.baseUrl;
                            if (!kIsWeb && Platform.isAndroid) {}

                            final response = await http.put(
                              Uri.parse('$baseUrl/users/$_userId/password'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'old_password': oldPass,
                                'new_password': newPass,
                              }),
                            );

                            if (response.statusCode == 200) {
                              if (mounted) {
                                Navigator.pop(context); // Close dialog
                                _showCustomSnackBar(
                                  message: 'Password changed successfully',
                                  isError: false,
                                );
                              }
                            } else {
                              String errorMessage =
                                  'Failed to change password (Error ${response.statusCode})';
                              try {
                                final data = jsonDecode(response.body);
                                if (data['error'] != null) {
                                  errorMessage = data['error'];
                                }
                              } catch (_) {
                                // Not JSON
                              }

                              if (mounted) {
                                _showCustomSnackBar(
                                  message: errorMessage,
                                  isError: true,
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              _showCustomSnackBar(
                                message: 'Network error: $e',
                                isError: true,
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => isDialogLoading = false);
                            }
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Change',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final _deleteEmailController = TextEditingController();
    final _deletePasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'To delete your account, please enter your email and password to confirm. This action cannot be undone.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deleteEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deletePasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          final email = _deleteEmailController.text.trim();
                          final pass = _deletePasswordController.text;

                          if (email.isEmpty || pass.isEmpty) {
                            _showCustomSnackBar(
                              message: 'Please enter email and password',
                              isError: true,
                            );
                            return;
                          }

                          if (_userId == null) return;

                          setDialogState(() => isDialogLoading = true);

                          try {
                            String baseUrl = ApiConfig.baseUrl;

                            final request = http.Request(
                              'DELETE',
                              Uri.parse('$baseUrl/users/$_userId'),
                            );
                            request.headers['Content-Type'] =
                                'application/json';
                            request.body = jsonEncode({
                              'email': email,
                              'password': pass,
                            });

                            final streamedResponse = await request.send();
                            final response = await http.Response.fromStream(
                              streamedResponse,
                            );

                            if (response.statusCode == 200) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear(); // Clear all user data

                              if (mounted) {
                                Navigator.pop(context); // Close dialog
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomePage(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              String errorMessage =
                                  'Failed to delete account (Error ${response.statusCode})';
                              try {
                                final data = jsonDecode(response.body);
                                if (data['error'] != null) {
                                  errorMessage = data['error'];
                                }
                              } catch (_) {}

                              if (mounted) {
                                _showCustomSnackBar(
                                  message: errorMessage,
                                  isError: true,
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              _showCustomSnackBar(
                                message: 'Network error: $e',
                                isError: true,
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => isDialogLoading = false);
                            }
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
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

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE082), // Theme Yellow
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar with Close button
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Profile Picture
            Container(
              padding: const EdgeInsets.all(4), // white border thickness
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFE8F0FE,
                  ), // Light blue-grey background for avatar
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 55, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "My Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 35.0,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E232C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),

                      _buildSettingTile(
                        title: "Full Name",
                        subtitle: _usernameController.text.isNotEmpty
                            ? _usernameController.text
                            : "Loading...",
                        icon: Icons.person_outline,
                        onTap: _showChangeNameDialog,
                      ),

                      const Divider(height: 20, color: Colors.black12),

                      _buildSettingTile(
                        title: "Email Address",
                        subtitle: _emailController.text.isNotEmpty
                            ? _emailController.text
                            : "Loading...",
                        icon: Icons.email_outlined,
                        onTap: _showChangeEmailDialog,
                      ),

                      const Divider(height: 20, color: Colors.black12),

                      _buildSettingTile(
                        title: "Password",
                        subtitle: "••••••••",
                        icon: Icons.lock_outline,
                        onTap: _showChangePasswordDialog,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _showDeleteAccountDialog,
                        child: const Text(
                          "Delete Account",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFE91263), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E232C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }
}
