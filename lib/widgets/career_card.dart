import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/career_model.dart';

class CareerCard extends StatelessWidget {
  final CareerModel career;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  // ✅ Naye properties for customization
  final double elevation;
  final Color? shadowColor;
  final double borderRadius;

  const CareerCard({
    super.key,
    required this.career,
    this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
    this.elevation = 4,
    this.shadowColor,
    this.borderRadius = AppConstants.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shadowColor: shadowColor ?? Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Career Image
            Container(
              height: 140,
              width: double.infinity,
              color: AppColors.industryColors[career.industry]?.withOpacity(0.1) ??
                  AppColors.primary.withOpacity(0.1),
              child: career.imageUrl != null && career.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: career.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.background,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.background,
                  child: Icon(
                    Icons.work_outline,
                    size: 40,
                    color: AppColors.industryColors[career.industry] ??
                        AppColors.primary,
                  ),
                ),
              )
                  : Icon(
                Icons.work_outline,
                size: 40,
                color: AppColors.industryColors[career.industry] ??
                    AppColors.primary,
              ),
            ),

            // Career Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              career.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (AppColors.industryColors[career.industry] ??
                                    AppColors.primary)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                career.industry,
                                style: TextStyle(
                                  color: AppColors.industryColors[career.industry] ??
                                      AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onBookmark != null)
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? AppColors.accent : AppColors.textSecondary,
                          ),
                          onPressed: onBookmark,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    career.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Skills Wrap
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: career.requiredSkills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Text(
                          skill,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (career.requiredSkills.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '+${career.requiredSkills.length - 3} more skills',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Salary & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 16, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            career.salaryRange,
                            style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            career.averageRatingText,
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // View Count
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${career.viewCount} views',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
