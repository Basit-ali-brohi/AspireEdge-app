// file: quiz_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
class QuizModel {
  final String questionId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final Map<String, int> scoreMap;
  final String category;
  final int questionOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuizModel({
    required this.questionId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.scoreMap,
    required this.category,
    required this.questionOrder,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'scoreMap': scoreMap,
      'category': category,
      'questionOrder': questionOrder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return QuizModel(
      questionId: docId ?? map['questionId'] ?? '',
      questionText: map['questionText'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      optionC: map['optionC'] ?? '',
      optionD: map['optionD'] ?? '',
      scoreMap: Map<String, int>.from(
          (map['scoreMap'] ?? {}).map((k, v) => MapEntry(k.toString(), v is int ? v : int.tryParse(v.toString()) ?? 0))),
      category: map['category'] ?? 'General',
      questionOrder: map['questionOrder'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory QuizModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel.fromMap(data, docId: doc.id);
  }

  QuizModel copyWith({
    String? questionId,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    Map<String, int>? scoreMap,
    String? category,
    int? questionOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      scoreMap: scoreMap ?? this.scoreMap,
      category: category ?? this.category,
      questionOrder: questionOrder ?? this.questionOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  List<String> get options => [optionA, optionB, optionC, optionD];

  int getScoreForOption(String option) => scoreMap[option] ?? 0;

  @override
  String toString() {
    return 'QuizModel(questionId: $questionId, questionText: $questionText, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizModel && other.questionId == questionId;
  }

  @override
  int get hashCode => questionId.hashCode;
}

// ----------------------
// Quiz Result Model
// ----------------------
// file: quiz_result_model.dart



class QuizResultModel {
  final String resultId;
  final String userId;
  final Map<String, int> categoryScores;
  final String recommendedTier;
  final List<String> recommendedCareers;
  final Map<String, dynamic> detailedAnalysis;
  final DateTime completedAt;
  final int totalQuestions;

  QuizResultModel({
    required this.resultId,
    required this.userId,
    required this.categoryScores,
    required this.recommendedTier,
    required this.recommendedCareers,
    required this.detailedAnalysis,
    required this.completedAt,
    required this.totalQuestions,
  });

  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'userId': userId,
      'categoryScores': categoryScores,
      'recommendedTier': recommendedTier,
      'recommendedCareers': recommendedCareers,
      'detailedAnalysis': detailedAnalysis,
      'completedAt': Timestamp.fromDate(completedAt),
      'totalQuestions': totalQuestions,
    };
  }

  factory QuizResultModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return QuizResultModel(
      resultId: docId ?? map['resultId'] ?? '',
      userId: map['userId'] ?? '',
      categoryScores: Map<String, int>.from(
          (map['categoryScores'] ?? {}).map((k, v) => MapEntry(k.toString(), v is int ? v : int.tryParse(v.toString()) ?? 0))),
      recommendedTier: map['recommendedTier'] ?? '',
      recommendedCareers: List<String>.from(map['recommendedCareers'] ?? []),
      detailedAnalysis: Map<String, dynamic>.from(map['detailedAnalysis'] ?? {}),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalQuestions: map['totalQuestions'] ?? 0,
    );
  }

  factory QuizResultModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizResultModel.fromMap(data, docId: doc.id);
  }

  static String _calculateTier(Map<String, int> categoryScores) {
    if (categoryScores.isEmpty) return 'Beginner';
    final topCategory = categoryScores.entries.reduce((a, b) => a.value > b.value ? a : b);

    if (topCategory.value > 10) return 'Expert';
    if (topCategory.value > 5) return 'Intermediate';
    return 'Beginner';
  }

  static QuizResultModel calculateResult({
    required String userId,
    required List<QuizModel> quizzes,
    required Map<String, String> userAnswers,
  }) {
    Map<String, int> categoryScores = {
      'Interests': 0,
      'Skills': 0,
      'Personality': 0,
      'Values': 0,
    };

    userAnswers.forEach((questionId, selectedOptionKey) {
      try {
        final question = quizzes.firstWhere((q) => q.questionId == questionId);

        final score = question.getScoreForOption(selectedOptionKey);
        final category = question.category;

        categoryScores.update(category, (value) => value + score, ifAbsent: () => score);
      } catch (e) {
        debugPrint('Error finding question or option: $e');
      }
    });

    final recommendedTier = _calculateTier(categoryScores);
    final totalQuestions = quizzes.length;

    return QuizResultModel(
      resultId: 'quiz_result_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      categoryScores: categoryScores,
      recommendedTier: recommendedTier,
      recommendedCareers: [],
      detailedAnalysis: {},
      completedAt: DateTime.now(),
      totalQuestions: totalQuestions,
    );
  }

  @override
  String toString() {
    return 'QuizResultModel(resultId: $resultId, userId: $userId, recommendedTier: $recommendedTier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizResultModel && other.resultId == resultId;
  }

  @override
  int get hashCode => resultId.hashCode;
}