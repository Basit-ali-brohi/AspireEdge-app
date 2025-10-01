import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/resource_model.dart';

class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback? onTap;

  // Wishlist
  final VoidCallback? onWishlistToggle;
  final bool isWishlisted;

  // ✅ Bookmark
  final VoidCallback? onBookmarkToggle;
  final bool isBookmarked;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.onWishlistToggle,
    this.isWishlisted = false,
    this.onBookmarkToggle,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Image/Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius),
                topRight: Radius.circular(AppConstants.borderRadius),
              ),
              child: Container(
                height: 160,
                width: double.infinity,
                color: _getResourceColor().withOpacity(0.1),
                child: resource.thumbnailUrl != null
                    ? CachedNetworkImage(
                  imageUrl: resource.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: _getResourceColor().withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _getResourceColor(),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: _getResourceColor().withOpacity(0.1),
                    child: Icon(
                      _getResourceIcon(),
                      size: 40,
                      color: _getResourceColor(),
                    ),
                  ),
                )
                    : Icon(
                  _getResourceIcon(),
                  size: 40,
                  color: _getResourceColor(),
                ),
              ),
            ),

            // Resource Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Wishlist & Bookmark
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getResourceColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    resource.typeDisplayName,
                                    style: TextStyle(
                                      color: _getResourceColor(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.lightGrey),
                                  ),
                                  child: Text(
                                    resource.category,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Wishlist button
                      if (onWishlistToggle != null)
                        IconButton(
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : AppColors.textSecondary,
                          ),
                          onPressed: onWishlistToggle,
                        ),

                      // ✅ Bookmark button
                      if (onBookmarkToggle != null)
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
                          ),
                          onPressed: onBookmarkToggle,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    resource.shortDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Author and Date
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        resource.author ?? 'Unknown',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textHint),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(resource.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textHint),
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

  Color _getResourceColor() {
    switch (resource.resourceType.toLowerCase()) {
      case 'blog':
        return AppColors.info;
      case 'ebook':
        return AppColors.primary;
      case 'video':
        return AppColors.error;
      case 'podcast':
        return AppColors.accent;
      case 'template':
        return AppColors.success;
      case 'guide':
        return AppColors.secondary;
      case 'webinar':
        return AppColors.warning;
      case 'course':
      case 'career':
        return AppColors.professionalColor;
      default:
        return AppColors.primary;
    }
  }

  IconData _getResourceIcon() {
    switch (resource.resourceType.toLowerCase()) {
      case 'blog':
        return Icons.article;
      case 'ebook':
        return Icons.book;
      case 'video':
        return Icons.play_circle;
      case 'podcast':
        return Icons.mic;
      case 'template':
        return Icons.description;
      case 'guide':
        return Icons.info;
      case 'webinar':
        return Icons.video_call;
      case 'course':
      case 'career':
        return Icons.school;
      default:
        return Icons.library_books;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}
