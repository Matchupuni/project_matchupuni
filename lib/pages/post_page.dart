import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_page.dart';
import 'my_posts_page.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final List<String> _availableTags = [
    'All',
    'Competition',
    'Camp & Workshop',
    'Business & Startup',
    'Tech & AI',
    'Creative & Design',
    'Other',
  ];
  final List<String> _selectedTags = [];
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;
  bool _isActivitySelected = true;
  final List<String> _selectedTypes = [];

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _registerLinkController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  final TextEditingController _roleNeededController = TextEditingController();
  final TextEditingController _teammatesNeededController =
      TextEditingController();
  final TextEditingController _requiredSkillController =
      TextEditingController();

  final List<String> _competitionTypes = [
    'Software & App Development',
    'Data Science & AI',
    'Cybersecurity',
    'Business & Strategy',
    'Hardware & Engineering',
    'Design & Creative',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _registerLinkController.dispose();
    _contactController.dispose();
    _roleNeededController.dispose();
    _teammatesNeededController.dispose();
    _requiredSkillController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A8AF4),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
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
                        const SizedBox(width: 40), // Spacer for centering
                        const Text(
                          "Create Post",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyPostsPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.history,
                              color: Color(0xFFE91E63),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildToggleButtons(),
                    const SizedBox(height: 16),
                    _buildPhotoUploadBox(),
                    const SizedBox(height: 20),
                    if (_isActivitySelected) ...[
                      _buildLabelRow(
                        "Name:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _nameController,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Details:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _detailsController,
                            maxLines: 4,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Due Date:",
                        _withRequiredIndicator(_buildDueDateField()),
                      ),
                      _buildLabelRow(
                        "Register:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _registerLinkController,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Contact:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _contactController,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Tags:",
                        _withRequiredIndicator(_buildTagsRow()),
                      ),
                    ] else ...[
                      // --- General Info ---
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "General Info",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Name:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _nameController,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Details:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _detailsController,
                            maxLines: 4,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Type:",
                        _withRequiredIndicator(_buildTypeRow()),
                      ),
                      _buildLabelRow(
                        "Due Date:",
                        _withRequiredIndicator(_buildDueDateField()),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                      ),

                      // --- Recruitment ---
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Recruitment",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Role Needed:",
                        _buildTextField(
                          "Type here....",
                          controller: _roleNeededController,
                        ),
                      ),
                      _buildLabelRow(
                        "Required Skill:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _requiredSkillController,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Teammates Needed:",
                        _withRequiredIndicator(
                          _buildNumberCounter(
                            controller: _teammatesNeededController,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Contact:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _contactController,
                          ),
                        ),
                      ),
                      _buildLabelRow(
                        "Register:",
                        _withRequiredIndicator(
                          _buildTextField(
                            "Type here....",
                            controller: _registerLinkController,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildNoteText(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          const CustomBottomNav(selectedIndex: 1),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      height: 38,
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
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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
                  color: const Color(0xFF4A8AF4),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    _isActivitySelected ? "Activity" : "Find Teammates",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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

  Widget _buildPhotoUploadBox() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD3DEF5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _selectedImages.isEmpty
            ? _buildPlaceholderContent()
            : _buildImageGrid(),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.image, size: 50, color: Color(0xFFD3DEF5)),
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F7FC),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: Color(0xFFD3DEF5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Add Your Photo",
            style: TextStyle(
              color: Color(0xFF8FA5C1),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.horizontal,
      itemCount: _selectedImages.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return GestureDetector(
            onTap: _pickImages,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD3DEF5),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(Icons.add_a_photo, color: Color(0xFF8FA5C1)),
            ),
          );
        }
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabelRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16.0,
      ), // increased padding for breathing room
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .center, // center align label and field vertically
        children: [
          SizedBox(
            width: 80, // slightly adjusted width
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 12), // gap between label and field
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Container(
      // width: 220, // Removed fixed width to allow expansion
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCounter({required TextEditingController controller}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.black54),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? 1;
              if (currentValue > 1) {
                setState(() {
                  controller.text = (currentValue - 1).toString();
                });
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "1",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black54),
            onPressed: () {
              int currentValue = int.tryParse(controller.text) ?? 0;
              if (currentValue == 0 && controller.text.isEmpty) {
                currentValue = 1;
              }
              setState(() {
                controller.text = (currentValue + 1).toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRow() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._selectedTypes.map((type) => _buildChip(type, _selectedTypes)),
        _buildAddButton(
          title: "Add Type",
          availableItems: _competitionTypes,
          selectedItems: _selectedTypes,
        ),
      ],
    );
  }

  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._selectedTags.map((tag) => _buildChip(tag, _selectedTags)),
        _buildAddButton(
          title: "Add Tag",
          availableItems: _availableTags,
          selectedItems: _selectedTags,
        ),
      ],
    );
  }

  Widget _buildAddButton({
    required String title,
    required List<String> availableItems,
    required List<String> selectedItems,
  }) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      tooltip: title,
      onSelected: (String item) {},
      itemBuilder: (BuildContext context) {
        return availableItems.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            enabled: false,
            child: StatefulBuilder(
              builder: (context, setPopupState) {
                bool isSelected = selectedItems.contains(item);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedItems.remove(item);
                      } else {
                        selectedItems.add(item);
                      }
                    });
                    setPopupState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                          color: const Color(0xFF4A8AF4),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList();
      },
      child: Container(
        width: 38,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFD3DEF5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.add, size: 16, color: Color(0xFF8FA5C1)),
      ),
    );
  }

  Widget _buildChip(String text, List<String> selectedItems) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItems.remove(text);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4A8AF4),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // Helper to wrap fields with the '*' next to them based on length
  Widget _withRequiredIndicator(Widget child) {
    return Row(
      // Changed Wrap to Row for better control within the Expanded parent
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: child), // Field takes remaining space
        const SizedBox(width: 8),
        const Text(
          '*',
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedDate == null
                  ? 'DD/MM/YYYY'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null
                    ? Colors.grey[400]
                    : Colors.black87,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, color: Colors.black87, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Name for the post')),
      );
      return;
    }

    String details = _detailsController.text.trim();
    String? uploadedImagePath;

    try {
      if (_selectedImages.isNotEmpty) {
        var uploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:3000/upload'),
        );
        uploadRequest.files.add(
          await http.MultipartFile.fromPath('file', _selectedImages.first.path),
        );

        var uploadResponse = await uploadRequest.send();
        if (uploadResponse.statusCode == 200) {
          var responseData = await http.Response.fromStream(uploadResponse);
          var jsonMap = json.decode(responseData.body);
          uploadedImagePath =
              jsonMap['path']; // Gets something like /public/uploads/...
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
          return;
        }
      }

      final Map<String, dynamic> payload = {
        "name": name,
        "details": details,
        "due_date": _selectedDate?.toUtc().toIso8601String(),
        "register_link": _registerLinkController.text.trim(),
        "image_path": uploadedImagePath,
        "tags": _isActivitySelected ? _selectedTags : [],
        "fields": !_isActivitySelected ? _selectedTypes : [],
        "post_type": _isActivitySelected ? "activity" : "team",
        "role_needed": _isActivitySelected
            ? null
            : _roleNeededController.text.trim(),
        "teammates_needed": _isActivitySelected
            ? null
            : int.tryParse(_teammatesNeededController.text.trim()),
        "required_skill": _isActivitySelected
            ? null
            : _requiredSkillController.text.trim(),
        "contact": _contactController.text.trim(),
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post Created Successfully!')),
          );
          // Navigate to Activity or clear form
          setState(() {
            _nameController.clear();
            _detailsController.clear();
            _registerLinkController.clear();
            _contactController.clear();
            _roleNeededController.clear();
            _teammatesNeededController.clear();
            _requiredSkillController.clear();
            _selectedTags.clear();
            _selectedTypes.clear();
            _selectedDate = null;
            _selectedImages.clear();
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.statusCode} - ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to server: $e')),
        );
      }
    }
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submitPost,
      child: Container(
        width: 180,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Create now",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        children: [
          const TextSpan(
            text: "Note: ",
            style: TextStyle(
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text:
                "Your post is pending review by an admin. You can track\nthe status in your Posting History.",
            style: TextStyle(height: 1.4, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
