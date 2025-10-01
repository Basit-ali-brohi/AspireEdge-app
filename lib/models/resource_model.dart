import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String resourceId;
  final String title;
  final String description;
  final String resourceType; // Blog, EBook, Video, Podcast, Template, Guide, Webinar, Course, Career
  final String category;
  final String? content; // For blogs or career detailed content
  final String? fileUrl; // For downloadable files
  final String? videoUrl; // For videos
  final String? thumbnailUrl;
  final String? author;
  final List<String> tags;
  final int viewCount;
  final int downloadCount;
  final double rating;
  final int ratingCount;
  final bool isBookmarkable;
  final bool isDownloadable;
  final bool isPremium;
  final String? tier; // Which user tier this resource is for
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  // Career-specific fields
  final String? industry; // IT, Health, Design, Agriculture, etc.
  final List<String>? requiredSkills;
  final String? salaryRange;
  final String? educationPath;

  ResourceModel({
    required this.resourceId,
    required this.title,
    required this.description,
    required this.resourceType,
    required this.category,
    this.content,
    this.fileUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.author,
    this.tags = const [],
    this.viewCount = 0,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isBookmarkable = true,
    this.isDownloadable = false,
    this.isPremium = false,
    this.tier,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
    this.industry,
    this.requiredSkills,
    this.salaryRange,
    this.educationPath,
  });

  // ===== copyWith method =====
  ResourceModel copyWith({
    String? resourceId,
    String? title,
    String? description,
    String? resourceType,
    String? category,
    String? content,
    String? fileUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? author,
    List<String>? tags,
    int? viewCount,
    int? downloadCount,
    double? rating,
    int? ratingCount,
    bool? isBookmarkable,
    bool? isDownloadable,
    bool? isPremium,
    String? tier,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
    String? industry,
    List<String>? requiredSkills,
    String? salaryRange,
    String? educationPath,
  }) {
    return ResourceModel(
      resourceId: resourceId ?? this.resourceId,
      title: title ?? this.title,
      description: description ?? this.description,
      resourceType: resourceType ?? this.resourceType,
      category: category ?? this.category,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isBookmarkable: isBookmarkable ?? this.isBookmarkable,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      isPremium: isPremium ?? this.isPremium,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      industry: industry ?? this.industry,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      salaryRange: salaryRange ?? this.salaryRange,
      educationPath: educationPath ?? this.educationPath,
    );
  }

  // Firestore conversion
  Map<String, dynamic> toMap() {
    return {
      'resourceId': resourceId,
      'title': title,
      'description': description,
      'resourceType': resourceType,
      'category': category,
      'content': content,
      'fileUrl': fileUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'author': author,
      'tags': tags,
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'isBookmarkable': isBookmarkable,
      'isDownloadable': isDownloadable,
      'isPremium': isPremium,
      'tier': tier,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'metadata': metadata,
      'industry': industry,
      'requiredSkills': requiredSkills,
      'salaryRange': salaryRange,
      'educationPath': educationPath,
    };
  }

  factory ResourceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceModel(
      resourceId: data['resourceId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      resourceType: data['resourceType'] ?? '',
      category: data['category'] ?? '',
      content: data['content'],
      fileUrl: data['fileUrl'],
      videoUrl: data['videoUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      author: data['author'],
      tags: List<String>.from(data['tags'] ?? []),
      viewCount: data['viewCount'] ?? 0,
      downloadCount: data['downloadCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      isBookmarkable: data['isBookmarkable'] ?? true,
      isDownloadable: data['isDownloadable'] ?? false,
      isPremium: data['isPremium'] ?? false,
      tier: data['tier'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'],
      industry: data['industry'],
      requiredSkills: data['requiredSkills'] != null
          ? List<String>.from(data['requiredSkills'])
          : null,
      salaryRange: data['salaryRange'],
      educationPath: data['educationPath'],
    );
  }

  // Short description
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  // Display name for resource type
  String get typeDisplayName {
    switch (resourceType.toLowerCase()) {
      case 'blog':
        return 'Blog Post';
      case 'ebook':
        return 'E-Book';
      case 'video':
        return 'Video';
      case 'podcast':
        return 'Podcast';
      case 'template':
        return 'Template';
      case 'guide':
        return 'Guide';
      case 'webinar':
        return 'Webinar';
      case 'course':
        return 'Course';
      case 'career':
        return 'Career';
      default:
        return resourceType;
    }
  }

  // Media helpers
  bool get hasMedia => videoUrl != null || thumbnailUrl != null;
  bool get isVideo => resourceType.toLowerCase() == 'video' && videoUrl != null;
  bool get isDownloadableFile => fileUrl != null && isDownloadable;

  // Optional getter for UI
  String get averageRatingText => ratingCount > 0 ? rating.toStringAsFixed(1) : 'N/A';

  @override
  String toString() {
    return 'ResourceModel(resourceId: $resourceId, title: $title, resourceType: $resourceType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResourceModel && other.resourceId == resourceId;
  }

  @override
  int get hashCode => resourceId.hashCode;
}
