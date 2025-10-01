import 'package:cloud_firestore/cloud_firestore.dart';

class MultimediaModel {
  final String id;
  final String title;
  final String url;
  final String type; // 'video' or 'audio'
  final List<String> tags; // ✅ Ek String ki bajaye List<String>
  final bool active;
  final DateTime? createdAt;

  MultimediaModel({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    required this.tags, // ✅ tags ki list
    required this.active,
    this.createdAt,
  });

  // Firestore document se object create karne ke liye
  factory MultimediaModel.fromMap(Map<String, dynamic> map, String docId) {
    return MultimediaModel(
      id: docId,
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? 'video',
      tags: List<String>.from(map['tags'] ?? []), // ✅ Map se List<String> me convert
      active: map['active'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Object ko Firestore me save karne ke liye map me convert
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'type': type,
      'tags': tags, // ✅ tags ki list
      'active': active,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}