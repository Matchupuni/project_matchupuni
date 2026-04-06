import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Using controllers so we can edit the info and "save"
  final TextEditingController _usernameController = TextEditingController(text: 'PluemICT033');
  final TextEditingController _emailController = TextEditingController(text: 'pluem@gmail.com');

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile information saved.')
      ),
    );
    Navigator.pop(context); // Go back after saving
  }

  void _deleteInfo() {
    setState(() {
      _usernameController.clear();
      _emailController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Info cleared. Remember to save.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The pale yellowish background shown in photo2
      backgroundColor: const Color(0xFFFBE082),
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
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.black87, size: 20),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Profile Picture
            Container(
              padding: const EdgeInsets.all(4), // white border thickness
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE), // Light blue-grey background for avatar
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 25),

            // Username Field wrapped exactly like the pill shapes in photo2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _usernameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Email Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Bottom White Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Edit Profile Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E232C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Save Button
                      ElevatedButton(
                        onPressed: _saveInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91263), // Pink
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Save Info",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Delete Info Button
                      OutlinedButton(
                        onPressed: _deleteInfo,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFE91263), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Delete Info",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91263),
                          ),
                        ),
                      ),
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
}
