// AdminDashboardScreen.dart

import 'package:aspire_edge/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/feedback_model.dart';
import 'FeedbackManagementScreen.dart';
import 'user_management_screen.dart';
import 'career_management_screen.dart';
import 'quiz_management_screen.dart';
import 'resource_management_screen.dart';
import 'analytics_screen.dart';
import '../testimonials/TestimonialApprovalScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AdminMultimediaScreen.dart'; // ✅ Multimedia Screen import

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _totalCareers = 0;
  int _totalQuizzes = 0;
  int _totalResources = 0;
  int _totalFeedback = 0;
  int _totalTestimonials = 0;
  int _totalMultimedia = 0; // ✅ New
  bool _isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final careersSnapshot = await _firestore.collection('careers').get();
      final quizzesSnapshot = await _firestore.collection('quizzes').get();
      final resourcesSnapshot = await _firestore.collection('resources').get();
      final feedbackSnapshot = await _firestore.collection('feedback').get();
      final testimonialsSnapshot = await _firestore.collection('testimonials').get();
      final multimediaSnapshot = await _firestore.collection('multimedia').get(); // ✅ New

      setState(() {
        _totalUsers = usersSnapshot.docs.length;
        _totalCareers = careersSnapshot.docs.length;
        _totalQuizzes = quizzesSnapshot.docs.length;
        _totalResources = resourcesSnapshot.docs.length;
        _totalFeedback = feedbackSnapshot.docs.length;
        _totalTestimonials = testimonialsSnapshot.docs.length;
        _totalMultimedia = multimediaSnapshot.docs.length; // ✅ New
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, size: 40, color: AppColors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome to Admin Panel',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your career guidance platform',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Cards
            Text(
              'Platform Statistics',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(context, 'Total Users', _totalUsers.toString(),
                    Icons.people, AppColors.primary),
                _buildStatCard(context, 'Careers', _totalCareers.toString(),
                    Icons.work, AppColors.success),
                _buildStatCard(context, 'Quizzes', _totalQuizzes.toString(),
                    Icons.quiz, AppColors.info),
                _buildStatCard(context, 'Resources', _totalResources.toString(),
                    Icons.library_books, AppColors.accent),
                _buildStatCard(context, 'Testimonials', _totalTestimonials.toString(),
                    Icons.star, AppColors.warning),
                _buildStatCard(context, 'Feedback', _totalFeedback.toString(),
                    Icons.feedback, AppColors.secondary),
                _buildStatCard(context, 'Multimedia', _totalMultimedia.toString(), // ✅ New
                    Icons.video_library, AppColors.primary),
              ],
            ),

            const SizedBox(height: 24),

            // Management Tools
            Text(
              'Management Tools',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'User Management',
              'Manage users, roles, and permissions',
              Icons.people,
              AppColors.primary,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserManagementScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'Career Management',
              'Add, edit, and manage career information',
              Icons.work,
              AppColors.success,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CareerManagementScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'Quiz Management',
              'Create and manage career assessment quizzes',
              Icons.quiz,
              AppColors.info,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const QuizManagementScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'Resource Management',
              'Manage blogs, videos, and learning materials',
              Icons.library_books,
              AppColors.accent,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ResourceManagementScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'Multimedia Guidance',
              'Add, edit, and manage multimedia videos',
              Icons.video_library,
              AppColors.primary,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminMultimediaScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'Feedback Management',
              'View and manage user feedback',
              Icons.feedback,
              AppColors.secondary,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const FeedbackManagementScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'Testimonial Management',
              'Approve, edit, and delete testimonials',
              Icons.reviews,
              AppColors.warning,
                  () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                    const TestimonialManagementScreen(isAdmin: true),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, String title, String description, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
