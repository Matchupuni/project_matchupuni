import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  final String postTitle;
  final String postId;

  const ReportPage({super.key, required this.postTitle, required this.postId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Spam or misleading',
    'Inappropriate content',
    'Harassment or bullying',
    'False information',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          "Report Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are reporting:",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  widget.postTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3246),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Why are you reporting this post?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3246),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: _reasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(fontSize: 15)),
                      value: reason,
                      groupValue: _selectedReason,
                      activeColor: const Color(0xFFE91E63),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Additional Details (Optional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3246),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Provide more information about the issue...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4285F4)),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedReason == null || _isSubmitting
                      ? null
                      : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Submit Report",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to backend (could send to /reports on the Node server)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Report submitted. Admin will review this post soon.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Go back to the previous screen
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}
