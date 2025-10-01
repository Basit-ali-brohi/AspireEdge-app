import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../career/career_bank_screen.dart';
import 'quiz_screen.dart'; // ✅ Import the QuizScreen to navigate back

class QuizResultScreen extends StatefulWidget {
  final Map<String, dynamic> results;

  const QuizResultScreen({
    super.key,
    required this.results,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryScores =
    widget.results['categoryScores'] as Map<String, int>;
    final recommendedTier = widget.results['recommendedTier'] as String;
    final recommendedCareers = _getRecommendedCareers(categoryScores);
    final totalQuestions = widget.results['totalQuestions'] as int;
    final totalScore = _calculateTotalScore(categoryScores);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // ✅ Updated the onPressed to restart the quiz
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const QuizScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Congratulations Card
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.largePadding),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration,
                            size: 60,
                            color: AppColors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Congratulations!',
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
                            'You\'ve completed the career assessment',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recommended Tier
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildResultCard(
                    context,
                    'Recommended Career Tier',
                    Icons.workspace_premium,
                    recommendedTier,
                    _getTierColor(recommendedTier),
                    _getTierDescription(recommendedTier),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Total Score
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildResultCard(
                    context,
                    'Your Score',
                    Icons.quiz,
                    '$totalScore',
                    AppColors.info,
                    'Based on your responses to $totalQuestions questions',
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Category Breakdown
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSection(
                    context,
                    'Category Breakdown',
                    Icons.analytics,
                    child: Column(
                      children: categoryScores.entries.map((entry) {
                        final percentage = totalScore > 0
                            ? (entry.value / totalScore) * 100
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCategoryScore(
                            context,
                            entry.key,
                            entry.value,
                            percentage,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recommended Careers
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSection(
                    context,
                    'Recommended Careers',
                    Icons.work,
                    child: Column(
                      children: recommendedCareers.map((career) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildCareerRecommendation(context, career),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Action Buttons
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Explore Careers',
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const CareerBankScreen(),
                            ),
                          );
                        },
                        width: double.infinity,
                        icon: Icons.explore,
                      ),

                      const SizedBox(height: 16),

                      CustomButton(
                        text: 'Retake Quiz',
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const QuizScreen()),
                                (Route<dynamic> route) => false,
                          );
                        },
                        isOutlined: true,
                        width: double.infinity,
                        icon: Icons.refresh,
                      ),
                    ],
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

  int _calculateTotalScore(Map<String, int> scores) {
    if (scores.isEmpty) return 0;
    return scores.values.reduce((a, b) => a + b);
  }

  List<String> _getRecommendedCareers(Map<String, int> categoryScores) {
    if (categoryScores.isEmpty) {
      return ['General Career', 'Further Assessment Recommended'];
    }

    final topCategory = categoryScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    switch (topCategory.toLowerCase()) {
      case 'interests':
        return ['UX/UI Designer', 'Content Creator', 'Marketing Manager'];
      case 'skills':
        return ['Software Engineer', 'Data Analyst', 'Project Manager'];
      case 'personality':
        return ['Social Worker', 'Psychologist', 'Human Resources Manager'];
      case 'values':
        return ['Non-profit Manager', 'Environmental Scientist', 'Public Policy Analyst'];
      default:
        return ['General Career'];
    }
  }

  Widget _buildResultCard(
      BuildContext context,
      String title,
      IconData icon,
      String value,
      Color color,
      String description,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context,
      String title,
      IconData icon, {
        Widget? child,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (child != null) child,
      ],
    );
  }

  Widget _buildCategoryScore(
      BuildContext context, String category, int score, double percentage) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$score points',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage.isNaN ? 0.0 : (percentage / 100).toDouble(),
            backgroundColor: AppColors.lightGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerRecommendation(BuildContext context, String career) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.work,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              career,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case AppConstants.studentTier:
        return AppColors.studentColor;
      case AppConstants.graduateTier:
        return AppColors.graduateColor;
      case AppConstants.professionalTier:
        return AppColors.professionalColor;
      default:
        return AppColors.primary;
    }
  }

  String _getTierDescription(String tier) {
    switch (tier) {
      case AppConstants.studentTier:
        return 'Perfect for students exploring career options';
      case AppConstants.graduateTier:
        return 'Ideal for recent graduates starting their careers';
      case AppConstants.professionalTier:
        return 'Great for experienced professionals looking to advance';
      default:
        return 'Based on your quiz responses';
    }
  }
}