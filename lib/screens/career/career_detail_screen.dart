import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/career_model.dart';
import '../../widgets/custom_button.dart';

class CareerDetailScreen extends StatefulWidget {
  final CareerModel career;

  const CareerDetailScreen({
    super.key,
    required this.career,
  });

  @override
  State<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Career Image
                  CachedNetworkImage(
                    imageUrl: widget.career.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.industryColors[widget.career.industry]?.withOpacity(0.1) ?? 
                             AppColors.primary.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.industryColors[widget.career.industry]?.withOpacity(0.1) ?? 
                             AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.work,
                        size: 80,
                        color: AppColors.industryColors[widget.career.industry] ?? 
                               AppColors.primary,
                      ),
                    ),
                  ),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.career.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (AppColors.industryColors[widget.career.industry] ?? 
                                    AppColors.primary).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.career.industry,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.white),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview
                  _buildSection(
                    context,
                    'Overview',
                    Icons.info_outline,
                    widget.career.description,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Salary Information
                  _buildInfoCard(
                    context,
                    'Salary Range',
                    Icons.attach_money,
                    widget.career.salaryRange,
                    AppColors.success,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rating
                  _buildInfoCard(
                    context,
                    'Rating',
                    Icons.star,
                    widget.career.averageRatingText,
                    AppColors.warning,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // View Count
                  _buildInfoCard(
                    context,
                    'Views',
                    Icons.visibility,
                    '${widget.career.viewCount} views',
                    AppColors.info,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Required Skills
                  _buildSection(
                    context,
                    'Required Skills',
                    Icons.psychology,
                    null,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.career.requiredSkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Education Path
                  _buildSection(
                    context,
                    'Education Path',
                    Icons.school,
                    widget.career.educationPath,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recommended Degrees
                  _buildSection(
                    context,
                    'Recommended Degrees',
                    Icons.workspace_premium,
                    null,
                    child: Column(
                      children: widget.career.recommendedDegrees.map((degree) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  degree,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Certifications
                  if (widget.career.certifications.isNotEmpty)
                    _buildSection(
                      context,
                      'Certifications',
                      Icons.verified,
                      null,
                      child: Column(
                        children: widget.career.certifications.map((cert) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cert,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  const SizedBox(height: 32),

                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    String? content, {
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
        const SizedBox(height: 12),
        if (content != null)
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        if (child != null) child,
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    String value,
    Color color,
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
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
