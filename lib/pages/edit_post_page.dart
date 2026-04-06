import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_bottom_nav.dart';

class EditPostPage extends StatefulWidget {
  final Map<String, dynamic> cardData;
  const EditPostPage({super.key, required this.cardData});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
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
  List<String> _existingNetworkImages = [];
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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.cardData['name'] ?? '';
    _detailsController.text = widget.cardData['details'] ?? '';
    _registerLinkController.text = widget.cardData['register_link'] ?? '';
    _contactController.text = widget.cardData['contact'] ?? '';

    if (widget.cardData['tags'] != null) {
      _selectedTags.addAll(List<String>.from(widget.cardData['tags']));
    }
    if (widget.cardData['fields'] != null) {
      _selectedTypes.addAll(List<String>.from(widget.cardData['fields']));
    }

    final String? imgPathStr = widget.cardData['image_path']?.toString();
    if (imgPathStr != null && imgPathStr.isNotEmpty) {
      _existingNetworkImages = imgPathStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (widget.cardData['due_date'] != null) {
      _selectedDate = DateTime.tryParse(
        widget.cardData['due_date'].toString(),
      )?.toLocal();
    }

    _isActivitySelected =
        (widget.cardData['post_type'] ?? 'activity') == 'activity';

    if (!_isActivitySelected) {
      _roleNeededController.text = widget.cardData['role_needed'] ?? '';
      _teammatesNeededController.text =
          widget.cardData['teammates_needed']?.toString() ?? '';
      _requiredSkillController.text = widget.cardData['required_skill'] ?? '';
    }
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
            if (_existingNetworkImages.length + _selectedImages.length < 5) {
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
    final DateTime initial = _selectedDate ?? DateTime.now();
    final DateTime firstD = initial.isBefore(DateTime.now())
        ? initial
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstD,
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
                              Icons.arrow_back,
                              color: Color(0xFF333333),
                              size: 24,
                            ),
                          ),
                        ),
                        const Text(
                          "Edit Post",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ), // Spacer to keep title centered
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
      width: double.infinity,
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadBox() {
    final bool hasImages = _existingNetworkImages.isNotEmpty || _selectedImages.isNotEmpty;

    return GestureDetector(
      onTap: !hasImages ? _pickImages : null,
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
        child: !hasImages
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
    final int totalImages = _existingNetworkImages.length + _selectedImages.length;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.horizontal,
      itemCount: totalImages < 5 ? totalImages + 1 : 5,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index == totalImages) {
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

        final bool isNetwork = index < _existingNetworkImages.length;

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isNetwork
                  ? Image.network(
                      'http://localhost:3000${_existingNetworkImages[index]}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8F0FE),
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    )
                  : Image.file(
                      _selectedImages[index - _existingNetworkImages.length],
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
                    if (isNetwork) {
                      _existingNetworkImages.removeAt(index);
                    } else {
                      _selectedImages.removeAt(index - _existingNetworkImages.length);
                    }
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

    // 1. Photos Check (At least one image required - either existing or new)
    if (_existingNetworkImages.isEmpty && _selectedImages.isEmpty) {
      _showCustomSnackBar(
        message: 'Please provide at least one photo',
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
        _showCustomSnackBar(message: 'Please enter a Register link', isError: true);
        return;
      }
      if (_contactController.text.trim().isEmpty) {
        _showCustomSnackBar(message: 'Please enter Contact info', isError: true);
        return;
      }
      if (_selectedTags.isEmpty) {
        _showCustomSnackBar(message: 'Please select at least one Tag', isError: true);
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
        _showCustomSnackBar(message: 'Please enter Required Skills', isError: true);
        return;
      }
      if (_teammatesNeededController.text.trim().isEmpty || 
          _teammatesNeededController.text.trim() == "0") {
        _showCustomSnackBar(message: 'Please specify Teammates Needed', isError: true);
        return;
      }
      if (_contactController.text.trim().isEmpty) {
        _showCustomSnackBar(message: 'Please enter Contact info', isError: true);
        return;
      }
      if (_registerLinkController.text.trim().isEmpty) {
        _showCustomSnackBar(message: 'Please enter a Register link', isError: true);
        return;
      }
    }
    String finalImagePath = _existingNetworkImages.join(',');

    try {
      if (_selectedImages.isNotEmpty) {
        var uploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:3000/upload'),
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
          final String newUploadedPaths = (jsonMap['paths'] as List).join(',');
          
          if (finalImagePath.isNotEmpty) {
            finalImagePath = '$finalImagePath,$newUploadedPaths';
          } else {
            finalImagePath = newUploadedPaths;
          }
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
        "image_path": finalImagePath,
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

      final response = await http.put(
        Uri.parse('http://localhost:3000/posts/${widget.cardData['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showCustomSnackBar(
            message: 'Post Updated Successfully!',
            isError: false,
          );
          // Go back to the 'My Posts' page and signal a successful edit
          Navigator.pop(context, true);
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
            "Save Changes",
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

  void _showCustomSnackBar({
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.check_circle_outline,
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
            );
          },
        ),
        backgroundColor:
            isError ? const Color(0xFFE91E63) : const Color(0xFF4A8AF4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }
}
