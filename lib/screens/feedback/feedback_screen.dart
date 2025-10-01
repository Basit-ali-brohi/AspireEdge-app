import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/feedback_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  String _feedbackType = 'General';
  bool _isSubmitting = false;

  final List<String> _feedbackTypes = [
    'General',
    'Bug Report',
    'Feature Request',
    'Complaint',
    'Suggestion',
    'Appreciation',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill fields from current Firebase user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      // Optional: phone number if stored in Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          if (data.containsKey('phone')) {
            _phoneController.text = data['phone'] ?? '';
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final feedbackId = DateTime.now().millisecondsSinceEpoch.toString();

      FeedbackModel feedback = FeedbackModel(
        feedbackId: feedbackId,
        userId: FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        message: _messageController.text.trim(),
        feedbackType: _feedbackType,
        submittedAt: DateTime.now(),
      );

      await FirebaseService.instance.firestore
          .collection('feedback')
          .doc(feedback.feedbackId)
          .set(feedback.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text('Thank you for your feedback! We\'ll review it soon.'),
            backgroundColor: AppColors.success,
          ),
        );

        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _messageController.clear();
        setState(() => _feedbackType = 'General');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.largePadding),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius:
                  BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.feedback,
                      size: 40,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Share Your Feedback',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us improve AspireEdge with your valuable feedback',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Feedback Type
              Text(
                'Feedback Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  contentPadding:
                  const EdgeInsets.all(AppConstants.defaultPadding),
                ),
                items: _feedbackTypes
                    .map(
                      (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _feedbackType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Name Field
              CustomTextField(
                controller: _nameController,
                labelText: 'Your Name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email Field
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone Field
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number (Optional)',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Message Field
              Text(
                'Your Message',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                  'Tell us about your experience, suggestions, or any issues you faced...',
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  contentPadding:
                  const EdgeInsets.all(AppConstants.defaultPadding),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  if (value.length < 10) {
                    return 'Message should be at least 10 characters long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                onPressed: _isSubmitting ? null : _submitFeedback,
                width: double.infinity,
                icon: Icons.send,
              ),

              const SizedBox(height: 16),

              // Contact Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Other Ways to Reach Us',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildContactItem(
                        Icons.email,
                        'Email',
                        'basitbrohi078@gmail.com',
                      ),
                      const SizedBox(height: 8),
                      _buildContactItem(
                        Icons.phone,
                        'Phone',
                        '+92-3123681487',
                      ),
                      const SizedBox(height: 8),
                      _buildContactItem(
                        Icons.location_on,
                        'Address',
                        'aptech shahrah e faisal karachi',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
