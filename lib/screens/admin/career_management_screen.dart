import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/career_model.dart';

/// Career Service for Firestore
class CareerService {
  final CollectionReference _careersRef = FirebaseFirestore.instance.collection('careers');

  Future<void> createCareerFromMap(Map<String, dynamic> data) async {
    final docRef = _careersRef.doc();
    data['careerId'] = docRef.id;
    await docRef.set(data);
  }

  Future<void> updateCareer(String careerId, Map<String, dynamic> data) async {
    await _careersRef.doc(careerId).update(data);
  }

  Future<void> deleteCareer(String careerId) async {
    await _careersRef.doc(careerId).delete();
  }

  Stream<List<CareerModel>> streamCareers() {
    return _careersRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CareerModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }
}

/// Career Management Screen
class CareerManagementScreen extends StatefulWidget {
  const CareerManagementScreen({super.key});

  @override
  State<CareerManagementScreen> createState() => _CareerManagementScreenState();
}

class _CareerManagementScreenState extends State<CareerManagementScreen> {
  final CareerService _careerService = CareerService();
  List<CareerModel> _careers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedIndustry = 'All';

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  void _loadCareers() {
    setState(() => _isLoading = true);
    _careerService.streamCareers().listen((careers) {
      setState(() {
        _careers = careers;
        _isLoading = false;
      });
    }, onError: (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading careers: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addCareer),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCareersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search careers...',
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
                _buildFilterChip('All', _selectedIndustry == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('IT', _selectedIndustry == 'IT'),
                const SizedBox(width: 8),
                _buildFilterChip('Healthcare', _selectedIndustry == 'Healthcare'),
                const SizedBox(width: 8),
                _buildFilterChip('Design', _selectedIndustry == 'Design'),
                const SizedBox(width: 8),
                _buildFilterChip('Business', _selectedIndustry == 'Business'),
                const SizedBox(width: 8),
                _buildFilterChip('Education', _selectedIndustry == 'Education'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() {
        _selectedIndustry = selected ? label : 'All';
      }),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildCareersList() {
    final filteredCareers = _careers.where((career) {
      final matchesSearch = career.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          career.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesIndustry = _selectedIndustry == 'All' || career.industry == _selectedIndustry;
      return matchesSearch && matchesIndustry;
    }).toList();

    if (filteredCareers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No careers found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCareers.length,
      itemBuilder: (context, index) => _buildCareerCard(filteredCareers[index]),
    );
  }

  Widget _buildCareerCard(CareerModel career) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.work, color: AppColors.white),
        ),
        title: Text(career.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(career.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      career.industry,
                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '\$${career.salaryRange}', // 👈 Yahan symbol ₹ se $ me badla gaya
                    style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCareerAction(value, career),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(children: [Icon(Icons.visibility, size: 20), SizedBox(width: 8), Flexible(child: Text('View Details', overflow: TextOverflow.ellipsis))]),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Flexible(child: Text('Edit Career', overflow: TextOverflow.ellipsis))]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [Icon(Icons.delete, size: 20, color: AppColors.error), SizedBox(width: 8), Flexible(child: Text('Delete Career', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.error)))]),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCareerAction(String action, CareerModel career) {
    switch (action) {
      case 'view':
        _showCareerDetails(career);
        break;
      case 'edit':
        _editCareer(career);
        break;
      case 'delete':
        _deleteCareer(career);
        break;
    }
  }

  void _showCareerDetails(CareerModel career) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(career.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Industry', career.industry),
              _buildDetailRow('Description', career.description),
              _buildDetailRow('Salary Range', '\$${career.salaryRange}'), // 👈 Yahan bhi symbol badla gaya
              _buildDetailRow('Skills', career.skillsText),
              _buildDetailRow('Education Path', career.educationPath),
              _buildDetailRow('Degrees', career.degreesText),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _addCareer() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CareerDialog(),
    );
    if (result != null) {
      await _careerService.createCareerFromMap(result);
    }
  }

  void _editCareer(CareerModel career) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CareerDialog(career: career),
    );
    if (result != null) {
      await _careerService.updateCareer(career.careerId, result);
    }
  }

  void _deleteCareer(CareerModel career) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${career.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      await _careerService.deleteCareer(career.careerId);
    }
  }
}

/// Dialog for Add/Edit Career
class CareerDialog extends StatefulWidget {
  final CareerModel? career;
  const CareerDialog({super.key, this.career});

  @override
  State<CareerDialog> createState() => _CareerDialogState();
}

class _CareerDialogState extends State<CareerDialog> {
  late TextEditingController _titleController;
  late TextEditingController _industryController;
  late TextEditingController _descriptionController;
  late TextEditingController _salaryController;
  late TextEditingController _skillsController;
  late TextEditingController _educationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.career?.title ?? '');
    _industryController = TextEditingController(text: widget.career?.industry ?? '');
    _descriptionController = TextEditingController(text: widget.career?.description ?? '');
    _salaryController = TextEditingController(text: widget.career?.salaryRange ?? '');
    _skillsController = TextEditingController(text: widget.career?.requiredSkills.join(', ') ?? '');
    _educationController = TextEditingController(text: widget.career?.educationPath ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.career == null ? 'Add Career' : 'Edit Career'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField('Title', _titleController),
            const SizedBox(height: 8),
            _buildTextField('Industry', _industryController),
            const SizedBox(height: 8),
            _buildTextField('Description', _descriptionController, maxLines: 3),
            const SizedBox(height: 8),
            _buildTextField('Salary Range', _salaryController),
            const SizedBox(height: 8),
            _buildTextField('Required Skills (comma separated)', _skillsController),
            const SizedBox(height: 8),
            _buildTextField('Education Path', _educationController),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveCareer, child: const Text('Save')),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _saveCareer() {
    final data = {
      'title': _titleController.text.trim(),
      'industry': _industryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'salaryRange': _salaryController.text.trim(),
      'requiredSkills': _skillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'educationPath': _educationController.text.trim(),
      'recommendedDegrees': widget.career?.recommendedDegrees ?? [],
      'certifications': widget.career?.certifications ?? [],
      'relatedCareers': widget.career?.relatedCareers ?? [],
      'additionalInfo': widget.career?.additionalInfo ?? {},
      'imageUrl': widget.career?.imageUrl,
      'updatedAt': DateTime.now(),
      'createdAt': widget.career?.createdAt ?? DateTime.now(),
      'isActive': widget.career?.isActive ?? true,
      'viewCount': widget.career?.viewCount ?? 0,
      'rating': widget.career?.rating ?? 0.0,
      'ratingCount': widget.career?.ratingCount ?? 0,
    };
    Navigator.of(context).pop(data);
  }
}