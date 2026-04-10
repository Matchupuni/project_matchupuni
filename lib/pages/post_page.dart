import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_page.dart';
import 'my_posts_page.dart';
import 'package:project_matchupuni/config/api_config.dart';

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

  bool _isPickingImages = false;

  Future<void> _pickImages() async {
    if (_isPickingImages) return;
    setState(() {
      _isPickingImages = true;
    });

    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            if (_selectedImages.length < 5) {
              _selectedImages.add(File(image.path));
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImages = false;
        });
      }
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
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
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
                    const SizedBox(height: 8),
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
                        padding: EdgeInsets.only(top: 16.0, bottom: 24.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "General Info",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
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
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(thickness: 1, color: Color(0xFFE2E8F0)),
                      ),

                      // --- Recruitment ---
                      const Padding(
                        padding: EdgeInsets.only(bottom: 24.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Recruitment",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
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

  Widget _buildPhotoUploadBox() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.5,
            style: BorderStyle.values[1],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // เบาๆ ฟ้าอ่อน
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 36,
              color: Color(0xFF4A8AF4),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Click to upload photos",
            style: TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Max 5 photos (JPG, PNG)",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.horizontal,
      itemCount: _selectedImages.length < 5 ? _selectedImages.length + 1 : 5,
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

  Widget _buildLabelRow(String label, Widget child, {bool isRequired = false}) {
    // If the label ends with ':', let's strip it to look cleaner
    final String cleanLabel = label.endsWith(':')
        ? label.substring(0, label.length - 1)
        : label;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                text: cleanLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
                children: [
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Color(0xFFE91E63),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          child,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCounter({required TextEditingController controller}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              onTap: () {
                int currentValue = int.tryParse(controller.text) ?? 1;
                if (currentValue > 1) {
                  setState(() {
                    controller.text = (currentValue - 1).toString();
                  });
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.remove, color: Color(0xFFE91E63)),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "1",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              onTap: () {
                int currentValue = int.tryParse(controller.text) ?? 0;
                if (currentValue == 0 && controller.text.isEmpty) {
                  currentValue = 1;
                }
                setState(() {
                  controller.text = (currentValue + 1).toString();
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.add, color: Color(0xFF4A8AF4)),
              ),
            ),
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

  // Removed redundant asterisk inline - asterisks are better placed next to labels or assumed if all are required
  Widget _withRequiredIndicator(Widget child) {
    return child;
  }

  Widget _buildDueDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 52, // Match height of textfields
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? 'DD/MM/YYYY'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null
                    ? Colors.grey[400]
                    : const Color(0xFF334155),
                fontSize: 15,
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final String name = _nameController.text.trim();

    // 1. Photos Check
    if (_selectedImages.isEmpty) {
      _showCustomSnackBar(
        message: 'Please upload at least one photo',
        isError: true,
      );
      return;
    }

    // 2. Name Check
    if (name.isEmpty) {
      _showCustomSnackBar(
        message: 'Please enter a Name for the post',
        isError: true,
      );
      return;
    }

    // 3. Details Check
    String details = _detailsController.text.trim();
    if (details.isEmpty) {
      _showCustomSnackBar(
        message: 'Please enter Details for the post',
        isError: true,
      );
      return;
    }

    // 4. Mode Specific Checks
    if (_isActivitySelected) {
      // Activity Mode Requirements
      if (_selectedDate == null) {
        _showCustomSnackBar(message: 'Please select a Due Date', isError: true);
        return;
      }
      if (_registerLinkController.text.trim().isEmpty) {
        _showCustomSnackBar(
          message: 'Please enter a Register link',
          isError: true,
        );
        return;
      }
      if (_contactController.text.trim().isEmpty) {
        _showCustomSnackBar(
          message: 'Please enter Contact info',
          isError: true,
        );
        return;
      }
      if (_selectedTags.isEmpty) {
        _showCustomSnackBar(
          message: 'Please select at least one Tag',
          isError: true,
        );
        return;
      }
    } else {
      // Find Teammates Mode Requirements
      if (_selectedTypes.isEmpty) {
        _showCustomSnackBar(message: 'Please select a Type', isError: true);
        return;
      }
      if (_selectedDate == null) {
        _showCustomSnackBar(message: 'Please select a Due Date', isError: true);
        return;
      }
      if (_requiredSkillController.text.trim().isEmpty) {
        _showCustomSnackBar(
          message: 'Please enter Required Skills',
          isError: true,
        );
        return;
      }
      if (_teammatesNeededController.text.trim().isEmpty ||
          _teammatesNeededController.text.trim() == "0") {
        _showCustomSnackBar(
          message: 'Please specify Teammates Needed',
          isError: true,
        );
        return;
      }
      if (_contactController.text.trim().isEmpty) {
        _showCustomSnackBar(
          message: 'Please enter Contact info',
          isError: true,
        );
        return;
      }
      if (_registerLinkController.text.trim().isEmpty) {
        _showCustomSnackBar(
          message: 'Please enter a Register link',
          isError: true,
        );
        return;
      }
    }

    String? uploadedImagePath;

    try {
      if (_selectedImages.isNotEmpty) {
        var uploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/upload'),
        );
        for (var image in _selectedImages) {
          uploadRequest.files.add(
            await http.MultipartFile.fromPath('files', image.path),
          );
        }

        var uploadResponse = await uploadRequest.send();
        if (uploadResponse.statusCode == 200) {
          var responseData = await http.Response.fromStream(uploadResponse);
          var jsonMap = json.decode(responseData.body);
          uploadedImagePath = (jsonMap['paths'] as List).join(',');
        } else {
          if (mounted) {
            _showCustomSnackBar(
              message: 'Failed to upload image: ${uploadResponse.statusCode}',
              isError: true,
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

      // Fetch token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _showCustomSnackBar(
            message: 'Post Created Successfully!',
            isError: false,
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
          _showCustomSnackBar(
            message: 'Error: ${response.statusCode}',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar(
          message: 'Failed to connect to server: $e',
          isError: true,
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
}
