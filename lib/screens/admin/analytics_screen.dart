import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase instance
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firebase instance

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Load analytics data from Firebase
      final usersSnapshot = await _firestore.collection('users').get();
      final careersSnapshot = await _firestore.collection('careers').get();
      final quizzesSnapshot = await _firestore.collection('quiz_questions').get();
      final resourcesSnapshot = await _firestore.collection('resources').get();
      final feedbackSnapshot = await _firestore.collection('feedback').get();

      // Calculate analytics
      Map<String, int> userTiers = {};
      Map<String, int> careerIndustries = {};
      Map<String, int> resourceTypes = {};

      // User tier distribution
      for (var doc in usersSnapshot.docs) {
        String tier = doc.data()['tier'] ?? 'Unknown';
        userTiers[tier] = (userTiers[tier] ?? 0) + 1;
      }

      // Career industry distribution
      for (var doc in careersSnapshot.docs) {
        String industry = doc.data()['industry'] ?? 'Unknown';
        careerIndustries[industry] = (careerIndustries[industry] ?? 0) + 1;
      }

      // Resource type distribution
      for (var doc in resourcesSnapshot.docs) {
        String type = doc.data()['type'] ?? 'Unknown';
        resourceTypes[type] = (resourceTypes[type] ?? 0) + 1;
      }

      setState(() {
        _analytics = {
          'totalUsers': usersSnapshot.docs.length,
          'totalCareers': careersSnapshot.docs.length,
          'totalQuizzes': quizzesSnapshot.docs.length,
          'totalResources': resourcesSnapshot.docs.length,
          'totalFeedback': feedbackSnapshot.docs.length,
          'userTiers': userTiers,
          'careerIndustries': careerIndustries,
          'resourceTypes': resourceTypes,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
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
        title: const Text('Analytics & Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
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
            // Header
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
                  Icon(Icons.analytics, size: 40, color: AppColors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Platform Analytics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Insights and statistics about your platform',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overview Statistics
            Text(
              'Overview Statistics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(context, 'Total Users', _analytics['totalUsers'].toString(),
                    Icons.people, AppColors.primary),
                _buildStatCard(context, 'Total Careers', _analytics['totalCareers'].toString(),
                    Icons.work, AppColors.success),
                _buildStatCard(context, 'Total Quizzes', _analytics['totalQuizzes'].toString(),
                    Icons.quiz, AppColors.info),
                _buildStatCard(context, 'Total Resources', _analytics['totalResources'].toString(),
                    Icons.library_books, AppColors.accent),
              ],
            ),
            const SizedBox(height: 24),

            // User Tier Distribution
            _buildDistributionChart(context, 'User Tier Distribution',
                _analytics['userTiers'] as Map<String, int>, AppColors.primary),
            const SizedBox(height: 24),

            // Career Industry Distribution
            _buildDistributionChart(context, 'Career Industry Distribution',
                _analytics['careerIndustries'] as Map<String, int>, AppColors.success),
            const SizedBox(height: 24),

            // Resource Type Distribution
            _buildDistributionChart(context, 'Resource Type Distribution',
                _analytics['resourceTypes'] as Map<String, int>, AppColors.info),
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
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart(BuildContext context, String title, Map<String, int> data, Color color) {
    int total = data.values.fold(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (data.isEmpty)
              Center(
                child: Text('No data available',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
              )
            else
              ...data.entries.map((entry) {
                String key = entry.key;
                int value = entry.value;
                double percentage = total > 0 ? (value / total) * 100 : 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(key, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('$value (${percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: total > 0 ? value / total : 0,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
