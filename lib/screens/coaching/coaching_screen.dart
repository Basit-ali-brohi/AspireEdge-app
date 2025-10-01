import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/coaching_card.dart';
import 'stream_selector_screen.dart';
import 'cv_tips_screen.dart';
import 'interview_prep_screen.dart';

class CoachingScreen extends StatelessWidget {
  const CoachingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaching Tools'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
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
                    Icon(
                      Icons.school,
                      size: 40,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Career Coaching Tools',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get personalized guidance for your career journey',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Coaching Tools Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth < 400 ? 0.9 : 0.85,
                ),
                itemBuilder: (context, index) {
                  final cards = [
                    {
                      'title': 'Stream Selector',

                      'icon': Icons.school,
                      'color': AppColors.primary,
                      'screen': const StreamSelector(),
                    },
                    {
                      'title': 'CV Builder',
                      'icon': Icons.description,
                      'color': AppColors.secondary,
                      'screen': CvTipsPage(),
                    },
                    {
                      'title': 'Interview Prep',
                      'icon': Icons.record_voice_over,
                      'color': AppColors.accent,
                      'screen': const InterviewPrepPage (),
                    },
                    {
                      'title': 'Skill Assessment',
                      'icon': Icons.psychology,
                      'color': AppColors.success,
                      'screen': null,
                    },
                  ];

                  final card = cards[index];

                  return CoachingCard(
                    title: card['title'] as String,

                    icon: card['icon'] as IconData,
                    color: card['color'] as Color,
                    onTap: () {
                      if (card['screen'] != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => card['screen'] as Widget,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming Soon!'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // Quick Tips Section
              _buildQuickTipsSection(context),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuickTipsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Career Tips',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                _buildTipItem(
                  context,
                  Icons.lightbulb,
                  'Research thoroughly before choosing a career path',
                  'Take time to understand different career options and their requirements.',
                ),
                const Divider(),
                _buildTipItem(
                  context,
                  Icons.network_check,
                  'Build a strong professional network',
                  'Connect with professionals in your field of interest through LinkedIn and events.',
                ),
                const Divider(),
                _buildTipItem(
                  context,
                  Icons.trending_up,
                  'Keep learning and upskilling',
                  'Stay updated with industry trends and continuously improve your skills.',
                ),
                const Divider(),
                _buildTipItem(
                  context,
                  Icons.work,
                  'Gain practical experience',
                  'Look for internships, projects, or volunteer work in your chosen field.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(
      BuildContext context,
      IconData icon,
      String title,
      String description,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
