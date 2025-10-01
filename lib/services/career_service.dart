import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/career_model.dart';
import 'firebase_service.dart';

class CareerService {
  final FirebaseService _firebase = FirebaseService.instance;

  // Stream all careers with live updates
  Stream<List<CareerModel>> streamCareers() {
    return _firebase.careersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CareerModel.fromDocument(doc)).toList());
  }

  // Get a single career by ID
  Future<CareerModel> getCareer(String id) async {
    final doc = await _firebase.careersCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Career not found');
    }
    return CareerModel.fromDocument(doc);
  }

  // Create a new career
  Future<void> createCareer(CareerModel career) async {
    final docRef = _firebase.careersCollection.doc(); // Firestore auto-ID
    final newCareer = career.copyWith(careerId: docRef.id);
    final data = newCareer.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
  }

  // Update an existing career
  Future<void> updateCareer(String id, Map<String, dynamic> updateData) async {
    updateData['updatedAt'] = FieldValue.serverTimestamp();
    await _firebase.careersCollection.doc(id).update(updateData);
  }

  // Delete a career
  Future<void> deleteCareer(String id) async {
    await _firebase.careersCollection.doc(id).delete();
  }

  // Helper: create a career from a map (useful for Add/Edit dialogs)
  Future<void> createCareerFromMap(Map<String, dynamic> data) async {
    final docRef = _firebase.careersCollection.doc();
    final career = CareerModel(
      careerId: docRef.id,
      title: data['title'] ?? '',
      industry: data['industry'] ?? '',
      description: data['description'] ?? '',
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      salaryRange: data['salaryRange'] ?? '',
      educationPath: data['educationPath'] ?? '',
      recommendedDegrees: List<String>.from(data['recommendedDegrees'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      imageUrl: data['imageUrl'],
      relatedCareers: List<String>.from(data['relatedCareers'] ?? []),
      additionalInfo: data['additionalInfo'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      viewCount: 0,
      rating: 0.0,
      ratingCount: 0,
    );

    await docRef.set(career.toMap());
  }
}
