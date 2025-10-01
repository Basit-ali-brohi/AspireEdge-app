import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/quiz_model.dart';
import '../../services/firebase_service.dart';

class QuizManagementScreen extends StatefulWidget {
  const QuizManagementScreen({super.key});

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  List<QuizModel> _questions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['Interests', 'Skills', 'Personality', 'Values']; // Predefined categories

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
          .get();

      final questions = snapshot.docs
          .map((doc) => QuizModel.fromDocument(doc))
          .toList();

      questions.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addQuestion),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadQuestions),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search questions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedCategory == 'All'),
                      const SizedBox(width: 8),
                      ..._categories.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(c, _selectedCategory == c),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildQuestionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? label : 'All';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildQuestionsList() {
    final filteredQuestions = _questions.where((q) {
      final matchesSearch = q.questionText.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || q.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No questions found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredQuestions.length,
      itemBuilder: (context, index) => _buildQuestionCard(filteredQuestions[index]),
    );
  }

  Widget _buildQuestionCard(QuizModel q) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text('${q.questionOrder}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(q.questionText, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(q.category, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 4),
            Text('4 options', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleQuestionAction(value, q),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, size: 20), SizedBox(width: 8), Text('View Details')])),
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit Question')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: AppColors.error), SizedBox(width: 8), Text('Delete Question', style: TextStyle(color: AppColors.error))])),
          ],
        ),
      ),
    );
  }

  void _handleQuestionAction(String action, QuizModel q) {
    switch (action) {
      case 'view':
        _showQuestionDetails(q);
        break;
      case 'edit':
        _showAddEditDialog(editQuestion: q);
        break;
      case 'delete':
        _deleteQuestion(q);
        break;
    }
  }

  void _showQuestionDetails(QuizModel q) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Question ${q.questionOrder}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Category', q.category),
              _buildDetailRow('Question', q.questionText),
              const SizedBox(height: 8),
              const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...q.options.map((option) => Text('${String.fromCharCode(65 + q.options.indexOf(option))}. $option')).toList(),
              const SizedBox(height: 8),
              const Text('Scores:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...q.scoreMap.entries.map((entry) => Text('${entry.key}: ${entry.value}')).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _addQuestion() {
    _showAddEditDialog();
  }

  // Add/Edit Dialog with Dropdown for Category and Score fields
  void _showAddEditDialog({QuizModel? editQuestion}) {
    final questionController = TextEditingController(text: editQuestion?.questionText ?? '');
    final optionAController = TextEditingController(text: editQuestion?.optionA ?? '');
    final optionBController = TextEditingController(text: editQuestion?.optionB ?? '');
    final optionCController = TextEditingController(text: editQuestion?.optionC ?? '');
    final optionDController = TextEditingController(text: editQuestion?.optionD ?? '');
    final scoreAController = TextEditingController(text: editQuestion?.scoreMap['A']?.toString() ?? '0');
    final scoreBController = TextEditingController(text: editQuestion?.scoreMap['B']?.toString() ?? '0');
    final scoreCController = TextEditingController(text: editQuestion?.scoreMap['C']?.toString() ?? '0');
    final scoreDController = TextEditingController(text: editQuestion?.scoreMap['D']?.toString() ?? '0');
    String selectedCategory = editQuestion?.category ?? _categories.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(editQuestion != null ? 'Edit Question' : 'Add Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: questionController, decoration: const InputDecoration(labelText: 'Question')),
                    TextField(controller: optionAController, decoration: const InputDecoration(labelText: 'Option A')),
                    TextField(controller: optionBController, decoration: const InputDecoration(labelText: 'Option B')),
                    TextField(controller: optionCController, decoration: const InputDecoration(labelText: 'Option C')),
                    TextField(controller: optionDController, decoration: const InputDecoration(labelText: 'Option D')),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateInDialog(() => selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ..._buildScoreFields(
                      scoreAController,
                      scoreBController,
                      scoreCController,
                      scoreDController,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    _addOrUpdateQuestion(
                      editQuestion,
                      questionController,
                      optionAController,
                      optionBController,
                      optionCController,
                      optionDController,
                      scoreAController,
                      scoreBController,
                      scoreCController,
                      scoreDController,
                      selectedCategory,
                    );
                  },
                  child: Text(editQuestion != null ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildScoreFields(
      TextEditingController scoreAController,
      TextEditingController scoreBController,
      TextEditingController scoreCController,
      TextEditingController scoreDController,
      ) {
    return [
      const Text('Scores for each option:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      TextField(controller: scoreAController, decoration: const InputDecoration(labelText: 'Score for A'), keyboardType: TextInputType.number),
      TextField(controller: scoreBController, decoration: const InputDecoration(labelText: 'Score for B'), keyboardType: TextInputType.number),
      TextField(controller: scoreCController, decoration: const InputDecoration(labelText: 'Score for C'), keyboardType: TextInputType.number),
      TextField(controller: scoreDController, decoration: const InputDecoration(labelText: 'Score for D'), keyboardType: TextInputType.number),
    ];
  }

  void _addOrUpdateQuestion(
      QuizModel? editQuestion,
      TextEditingController questionController,
      TextEditingController optionAController,
      TextEditingController optionBController,
      TextEditingController optionCController,
      TextEditingController optionDController,
      TextEditingController scoreAController,
      TextEditingController scoreBController,
      TextEditingController scoreCController,
      TextEditingController scoreDController,
      String selectedCategory,
      ) async {
    final questionText = questionController.text.trim();
    final optionA = optionAController.text.trim();
    final optionB = optionBController.text.trim();
    final optionC = optionCController.text.trim();
    final optionD = optionDController.text.trim();
    final scoreA = int.tryParse(scoreAController.text) ?? 0;
    final scoreB = int.tryParse(scoreBController.text) ?? 0;
    final scoreC = int.tryParse(scoreCController.text) ?? 0;
    final scoreD = int.tryParse(scoreDController.text) ?? 0;

    if ([questionText, optionA, optionB, optionC, optionD].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all fields!'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    Navigator.of(context).pop();

    try {
      final scoreMap = {'A': scoreA, 'B': scoreB, 'C': scoreC, 'D': scoreD};

      if (editQuestion != null) {
        final updatedQuestion = editQuestion.copyWith(
          questionText: questionText,
          optionA: optionA,
          optionB: optionB,
          optionC: optionC,
          optionD: optionD,
          scoreMap: scoreMap,
          category: selectedCategory,
          updatedAt: DateTime.now(),
        );
        await FirebaseService.instance.firestore
            .collection('quiz_questions')
            .doc(editQuestion.questionId)
            .update(updatedQuestion.toMap());

        setState(() {
          final index = _questions.indexWhere((q) => q.questionId == editQuestion.questionId);
          if (index != -1) _questions[index] = updatedQuestion;
        });
      } else {
        final docRef = FirebaseService.instance.firestore.collection('quiz_questions').doc();
        final newQuestion = QuizModel(
          questionId: docRef.id,
          questionText: questionText,
          optionA: optionA,
          optionB: optionB,
          optionC: optionC,
          optionD: optionD,
          scoreMap: scoreMap,
          category: selectedCategory,
          questionOrder: _questions.length + 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await docRef.set(newQuestion.toMap());

        setState(() {
          _questions.add(newQuestion);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(editQuestion != null ? 'Question updated!' : 'Question added!'),
        backgroundColor: AppColors.primary,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _deleteQuestion(QuizModel q) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text('Are you sure you want to delete question ${q.questionOrder}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await FirebaseService.instance.firestore
                    .collection('quiz_questions')
                    .doc(q.questionId)
                    .delete();
                setState(() {
                  _questions.removeWhere((element) => element.questionId == q.questionId);
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Question deleted successfully!'),
                  backgroundColor: AppColors.warning,
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to delete question: $e'),
                  backgroundColor: AppColors.error,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}