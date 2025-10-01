// ResourceDetailScreen.dart (wishlist + bookmark enabled)
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/resource_model.dart';
import '../../widgets/custom_button.dart';

class ResourceDetailScreen extends StatefulWidget {
  final ResourceModel resource;

  const ResourceDetailScreen({
    super.key,
    required this.resource,
  });

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  bool _isBookmarked = false;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _loadWishlistStatus();
    _loadBookmarkStatus();
  }

  Future<void> _loadWishlistStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
    await FirebaseFirestore.instance.collection('wishlists').doc(uid).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _isWishlisted = data[widget.resource.resourceId] ?? false;
      });
    }
  }

  Future<void> _loadBookmarkStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
    await FirebaseFirestore.instance.collection('bookmarks').doc(uid).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _isBookmarked = data[widget.resource.resourceId] ?? false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isWishlisted = !_isWishlisted;
    });

    await FirebaseFirestore.instance
        .collection('wishlists')
        .doc(uid)
        .set({widget.resource.resourceId: _isWishlisted}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWishlisted ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(uid)
        .set({widget.resource.resourceId: _isBookmarked}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

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
                  // Resource Image
                  CachedNetworkImage(
                    imageUrl: widget.resource.thumbnailUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: _getResourceColor().withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: _getResourceColor().withOpacity(0.1),
                      child: Icon(
                        _getResourceIcon(),
                        size: 80,
                        color: _getResourceColor(),
                      ),
                    ),
                  ),
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
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resource.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getResourceColor().withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.resource.typeDisplayName,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.resource.category,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
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
            actions: [
              IconButton(
                icon: Icon(
                  _isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.white,
                ),
                onPressed: _toggleWishlist,
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.white,
                ),
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.white),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ],
          ),

          // Details Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author & Date
                  Row(
                    children: [
                      Icon(Icons.person,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'By ${widget.resource.author ?? 'Unknown'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(widget.resource.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      _buildStatItem(context, Icons.visibility,
                          '${widget.resource.viewCount}', 'Views'),
                      const SizedBox(width: 24),
                      _buildStatItem(context, Icons.star,
                          widget.resource.rating.toStringAsFixed(1), 'Rating'),
                      const SizedBox(width: 24),
                      _buildStatItem(context, Icons.people,
                          '${widget.resource.ratingCount}', 'Reviews'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _buildSection(context, 'Description', Icons.description,
                      widget.resource.description),
                  const SizedBox(height: 24),

                  // Video URL if available
                  if (widget.resource.videoUrl != null &&
                      widget.resource.videoUrl!.isNotEmpty)
                    _buildLinkSection(
                        context, 'Video Link', Icons.play_circle,
                        widget.resource.videoUrl!),

                  const SizedBox(height: 16),

                  // File URL if available
                  if (widget.resource.fileUrl != null &&
                      widget.resource.fileUrl!.isNotEmpty)
                    _buildLinkSection(
                        context, 'File Link', Icons.download,
                        widget.resource.fileUrl!),

                  const SizedBox(height: 24),

                  // Content
                  if (widget.resource.content != null)
                    _buildSection(context, 'Content', Icons.article,
                        widget.resource.content!),
                  const SizedBox(height: 24),

                  // Tags
                  if (widget.resource.tags.isNotEmpty)
                    _buildSection(
                      context,
                      'Tags',
                      Icons.tag,
                      null,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.resource.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Normal Section
  Widget _buildSection(BuildContext context, String title, IconData icon,
      String? content,
      {Widget? child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        if (content != null)
          Text(content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary, height: 1.5)),
        if (child != null) child,
      ],
    );
  }

  // Link Section (clickable URL)
  Widget _buildLinkSection(
      BuildContext context, String title, IconData icon, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _launchUrl(url),
          child: Text(
            url,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // Stats Builder
  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textHint)),
      ],
    );
  }

  // Resource Color
  Color _getResourceColor() {
    switch (widget.resource.resourceType.toLowerCase()) {
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

  // Resource Icon
  IconData _getResourceIcon() {
    switch (widget.resource.resourceType.toLowerCase()) {
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

  // Date Formatter
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  // URL Launcher
  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch URL'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
