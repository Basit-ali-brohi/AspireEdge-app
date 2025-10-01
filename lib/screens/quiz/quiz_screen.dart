// file: quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/quiz_model.dart';
import '../../widgets/quiz_question_card.dart';
import '../../widgets/progress_indicator_widget.dart';
import 'quiz_result_screen.dart';
import '../../services/firebase_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizModel> _questions = [];
  int _currentQuestionIndex = 0;
  // ✅ This map stores the selected option (e.g., 'A', 'B') for each question ID
  Map<String, String> _userAnswers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseService.instance.firestore
          .collection('quiz_questions')
          .orderBy('questionOrder')
          .get();
      final questions =
      snapshot.docs.map((doc) => QuizModel.fromDocument(doc)).toList();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load questions: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _selectAnswer(String questionId, String selectedOption) {
    setState(() {
      _userAnswers[questionId] = selectedOption;
    });
  }

  void _nextQuestion() {
    final currentQuestionId = _questions[_currentQuestionIndex].questionId;
    if (!_userAnswers.containsKey(currentQuestionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option before proceeding.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    final lastQuestionId = _questions.last.questionId;
    if (!_userAnswers.containsKey(lastQuestionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option before finishing.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // ✅ Here's the fix: Pass the entire _userAnswers map, not just its values as a list.
    // The previous QuizResultModel.calculateResult was expecting a List, but the new one expects a Map.
    final result = QuizResultModel.calculateResult(
      userId: 'your_user_id', // Replace with actual user ID
      quizzes: _questions,
      userAnswers: _userAnswers, // ✅ Corrected: Pass the full map
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(results: result.toMap()),
        ),
      );
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Career Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Career Quiz')),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 80, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text(
                  'No questions available',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    final selectedAnswerKey = _userAnswers[currentQuestion.questionId];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Career Quiz'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitQuiz,
            child: Text(
              'Submit',
              style: TextStyle(
                color: _isSubmitting ? AppColors.textHint : AppColors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: ProgressIndicatorWidget(
              progress: progress,
              currentStep: _currentQuestionIndex + 1,
              totalSteps: _questions.length,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding),
              child: SingleChildScrollView(
                child: QuizQuestionCard(
                  question: currentQuestion,
                  selectedAnswer: selectedAnswerKey,
                  onAnswerSelected: (answer) =>
                      _selectAnswer(currentQuestion.questionId, answer),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                        : Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}