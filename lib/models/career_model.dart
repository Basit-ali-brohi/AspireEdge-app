import 'package:cloud_firestore/cloud_firestore.dart';

class CareerModel {
  final String careerId;
  final String title;
  final String industry;
  final String description;
  final List<String> requiredSkills;
  final String salaryRange;
  final String educationPath;
  final List<String> recommendedDegrees;
  final List<String> certifications;
  final String? imageUrl;
  final List<String> relatedCareers;
  final Map<String, dynamic> additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int viewCount;
  final double rating;
  final int ratingCount;

  CareerModel({
    required this.careerId,
    required this.title,
    required this.industry,
    required this.description,
    required this.requiredSkills,
    required this.salaryRange,
    required this.educationPath,
    required this.recommendedDegrees,
    required this.certifications,
    this.imageUrl,
    this.relatedCareers = const [],
    this.additionalInfo = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.viewCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  // Convert CareerModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'careerId': careerId,
      'title': title,
      'industry': industry,
      'description': description,
      'requiredSkills': requiredSkills,
      'salaryRange': salaryRange,
      'educationPath': educationPath,
      'recommendedDegrees': recommendedDegrees,
      'certifications': certifications,
      'imageUrl': imageUrl,
      'relatedCareers': relatedCareers,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'viewCount': viewCount,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  // Create CareerModel from Firestore document
  factory CareerModel.fromMap(Map<String, dynamic> map) {
    return CareerModel(
      careerId: map['careerId'] ?? '',
      title: map['title'] ?? '',
      industry: map['industry'] ?? '',
      description: map['description'] ?? '',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      salaryRange: map['salaryRange'] ?? '',
      educationPath: map['educationPath'] ?? '',
      recommendedDegrees: List<String>.from(map['recommendedDegrees'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      imageUrl: map['imageUrl'],
      relatedCareers: List<String>.from(map['relatedCareers'] ?? []),
      additionalInfo: map['additionalInfo'] != null && map['additionalInfo'] is Map
          ? Map<String, dynamic>.from(map['additionalInfo'])
          : {},
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      viewCount: map['viewCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
    );
  }

  // Create CareerModel from Firestore document snapshot
  factory CareerModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CareerModel.fromMap(data);
  }

  // Copy with method for updating specific fields
  CareerModel copyWith({
    String? careerId,
    String? title,
    String? industry,
    String? description,
    List<String>? requiredSkills,
    String? salaryRange,
    String? educationPath,
    List<String>? recommendedDegrees,
    List<String>? certifications,
    String? imageUrl,
    List<String>? relatedCareers,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? viewCount,
    double? rating,
    int? ratingCount,
  }) {
    return CareerModel(
      careerId: careerId ?? this.careerId,
      title: title ?? this.title,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      salaryRange: salaryRange ?? this.salaryRange,
      educationPath: educationPath ?? this.educationPath,
      recommendedDegrees: recommendedDegrees ?? this.recommendedDegrees,
      certifications: certifications ?? this.certifications,
      imageUrl: imageUrl ?? this.imageUrl,
      relatedCareers: relatedCareers ?? this.relatedCareers,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  // Helper methods
  String get averageRatingText {
    if (ratingCount == 0) return 'No ratings yet';
    return '${rating.toStringAsFixed(1)} (${ratingCount} ratings)';
  }

  String get skillsText => requiredSkills.join(', ');

  String get degreesText => recommendedDegrees.join(', ');

  @override
  String toString() => 'CareerModel(careerId: $careerId, title: $title, industry: $industry)';

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CareerModel && other.careerId == careerId);

  @override
  int get hashCode => careerId.hashCode;
}
