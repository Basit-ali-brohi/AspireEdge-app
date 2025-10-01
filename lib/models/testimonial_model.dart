import 'package:cloud_firestore/cloud_firestore.dart';

class TestimonialModel {
  final String testimonialId;
  final String name;
  final String imageUrl;
  final String tier;
  final String story;
  final String? currentPosition;
  final String? company;
  final String? location;
  final List<String>? tags;
  final bool isActive;
  final bool approved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int displayOrder;

  TestimonialModel({
    required this.testimonialId,
    required this.name,
    required this.imageUrl,
    required this.tier,
    required this.story,
    this.currentPosition,
    this.company,
    this.location,
    this.tags,
    this.isActive = true,
    this.approved = false,
    required this.createdAt,
    required this.updatedAt,
    this.displayOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'testimonialId': testimonialId,
      'name': name,
      'imageUrl': imageUrl,
      'tier': tier,
      'story': story,
      'currentPosition': currentPosition,
      'company': company,
      'location': location,
      'tags': tags,
      'isActive': isActive,
      'approved': approved,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'displayOrder': displayOrder,
    };
  }

  // ✅ CORRECTED fromMap factory
  factory TestimonialModel.fromMap(Map<String, dynamic> map) {
    return TestimonialModel(
      testimonialId: map['testimonialId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tier: map['tier'] ?? '',
      story: map['story'] ?? '',
      currentPosition: map['currentPosition'],
      company: map['company'],
      location: map['location'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      isActive: map['isActive'] ?? true,
      approved: map['approved'] ?? false,
      createdAt: _getDateTimeFromMap(map, 'createdAt'), // ✅ Helper function use
      updatedAt: _getDateTimeFromMap(map, 'updatedAt'), // ✅ Helper function use
      displayOrder: map['displayOrder'] ?? 0,
    );
  }

  // From DocumentSnapshot
  factory TestimonialModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestimonialModel.fromMap(data);
  }

  // ✅ Helper method to handle both Timestamp and DateTime
  static DateTime _getDateTimeFromMap(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.now(); // Default value if type is unexpected
  }

  TestimonialModel copyWith({
    String? testimonialId,
    String? name,
    String? imageUrl,
    String? tier,
    String? story,
    String? currentPosition,
    String? company,
    String? location,
    List<String>? tags,
    bool? isActive,
    bool? approved,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? displayOrder,
  }) {
    return TestimonialModel(
      testimonialId: testimonialId ?? this.testimonialId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      tier: tier ?? this.tier,
      story: story ?? this.story,
      currentPosition: currentPosition ?? this.currentPosition,
      company: company ?? this.company,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      approved: approved ?? this.approved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  String get displayTitle {
    if (currentPosition != null && company != null) {
      return '$currentPosition at $company';
    } else if (currentPosition != null) {
      return currentPosition!;
    } else if (company != null) {
      return company!;
    }
    return tier;
  }

  String get shortStory {
    if (story.length <= 150) return story;
    return '${story.substring(0, 147)}...';
  }

  @override
  String toString() {
    return 'TestimonialModel(testimonialId: $testimonialId, name: $name, tier: $tier, approved: $approved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestimonialModel && other.testimonialId == testimonialId;
  }

  @override
  int get hashCode => testimonialId.hashCode;
}