import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String tier; // Student, Graduate, Professional, Admin
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? preferences;
  final List<String> bookmarkedCareers;
  final List<String> wishlistItems;
  final Map<String, dynamic>? quizResults;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.tier,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.preferences,
    this.bookmarkedCareers = const [],
    this.wishlistItems = const [],
    this.quizResults,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'tier': tier,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'preferences': preferences,
      'bookmarkedCareers': bookmarkedCareers,
      'wishlistItems': wishlistItems,
      'quizResults': quizResults,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      tier: map['tier'] ?? 'Student',
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      preferences: map['preferences'],
      bookmarkedCareers: List<String>.from(map['bookmarkedCareers'] ?? []),
      wishlistItems: List<String>.from(map['wishlistItems'] ?? []),
      quizResults: map['quizResults'],
    );
  }

  // Create UserModel from Firestore document snapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copy with method for updating specific fields
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? tier,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? preferences,
    List<String>? bookmarkedCareers,
    List<String>? wishlistItems,
    Map<String, dynamic>? quizResults,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      tier: tier ?? this.tier,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      bookmarkedCareers: bookmarkedCareers ?? this.bookmarkedCareers,
      wishlistItems: wishlistItems ?? this.wishlistItems,
      quizResults: quizResults ?? this.quizResults,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, email: $email, tier: $tier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
