import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String feedbackType; // positive, negative, suggestion, bug_report
  final String? category; // app, career, quiz, resources, etc.
  final int rating; // 1-5 stars
  final bool isResolved;
  final String? adminResponse;
  final DateTime submittedAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic>? metadata;

  FeedbackModel({
    required this.feedbackId,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.feedbackType,
    this.category,
    this.rating = 0,
    this.isResolved = false,
    this.adminResponse,
    required this.submittedAt,
    this.resolvedAt,
    this.metadata,
  });

  // Convert FeedbackModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'feedbackType': feedbackType,
      'category': category,
      'rating': rating,
      'isResolved': isResolved,
      'adminResponse': adminResponse,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'metadata': metadata,
    };
  }

  // Create FeedbackModel from Firestore document
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['feedbackId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      message: map['message'] ?? '',
      feedbackType: map['feedbackType'] ?? 'suggestion',
      category: map['category'],
      rating: map['rating'] ?? 0,
      isResolved: map['isResolved'] ?? false,
      adminResponse: map['adminResponse'],
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      metadata: map['metadata'],
    );
  }

  // Create FeedbackModel from Firestore document snapshot
  factory FeedbackModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel.fromMap(data);
  }

  // Copy with method for updating specific fields
  FeedbackModel copyWith({
    String? feedbackId,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? message,
    String? feedbackType,
    String? category,
    int? rating,
    bool? isResolved,
    String? adminResponse,
    DateTime? submittedAt,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FeedbackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      message: message ?? this.message,
      feedbackType: feedbackType ?? this.feedbackType,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      isResolved: isResolved ?? this.isResolved,
      adminResponse: adminResponse ?? this.adminResponse,
      submittedAt: submittedAt ?? this.submittedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  String get statusText {
    return isResolved ? 'Resolved' : 'Pending';
  }

  String get typeDisplayName {
    switch (feedbackType) {
      case 'positive':
        return 'Positive Feedback';
      case 'negative':
        return 'Negative Feedback';
      case 'suggestion':
        return 'Suggestion';
      case 'bug_report':
        return 'Bug Report';
      default:
        return 'General Feedback';
    }
  }

  String get ratingText {
    if (rating == 0) return 'No rating';
    return '${rating} star${rating > 1 ? 's' : ''}';
  }

  Duration get timeSinceSubmission {
    return DateTime.now().difference(submittedAt);
  }

  String get timeAgo {
    final duration = timeSinceSubmission;
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'FeedbackModel(feedbackId: $feedbackId, name: $name, feedbackType: $feedbackType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedbackModel && other.feedbackId == feedbackId;
  }

  @override
  int get hashCode => feedbackId.hashCode;
}
