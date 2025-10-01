import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/career_model.dart';
import '../../services/career_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/career_card.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/search_bar_widget.dart';
import 'career_detail_screen.dart';

class CareerBankScreen extends StatefulWidget {
  const CareerBankScreen({super.key});

  @override
  State<CareerBankScreen> createState() => _CareerBankScreenState();
}

class _CareerBankScreenState extends State<CareerBankScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final CareerService _careerService = CareerService();
  List<CareerModel> _allCareers = [];
  List<CareerModel> _filteredCareers = [];
  bool _isLoading = true;
  String _selectedIndustry = 'All';
  String _sortBy = 'title';
  bool _isAscending = true;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeCareers();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCareers() async {
    setState(() => _isLoading = true);
    final snapshot = await FirebaseService.instance.careersCollection.get();
    if (snapshot.docs.isEmpty) await _addTestCareer();
    _loadCareers();
  }

  Future<void> _addTestCareer() async {
    final Map<String, dynamic> data = {
      'title': 'Software Engineer',
      'industry': 'Information Technology',
      'description': 'Develop and maintain applications.',
      'requiredSkills': ['Dart', 'Flutter', 'Firebase'],
      'salaryRange': '50000-100000',
      'educationPath': 'BSc Computer Science',
      'recommendedDegrees': ['BSc CS'],
      'certifications': ['Flutter Certified Developer'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'viewCount': 0,
      'rating': 0.0,
      'ratingCount': 0,
      'relatedCareers': <String>[],
      'additionalInfo': '',
      'imageUrl': '',
    };
    await FirebaseService.instance.careersCollection.add(data);
  }

  void _loadCareers() {
    _careerService.streamCareers().listen((careers) {
      setState(() {
        _allCareers = careers;
        _filterCareers();
        _isLoading = false;
      });
    }, onError: (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load careers: $e'), backgroundColor: AppColors.error),
      );
    });
  }

  void _filterCareers() {
    _filteredCareers = _allCareers.where((career) {
      final matchesSearch = career.title
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()) ||
          career.industry
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          career.requiredSkills.any((skill) =>
              skill.toLowerCase().contains(_searchController.text.toLowerCase()));
      final matchesIndustry = _selectedIndustry == 'All' || career.industry == _selectedIndustry;
      return matchesSearch && matchesIndustry;
    }).toList();

    _sortCareers();
  }

  void _sortCareers() {
    _filteredCareers.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'industry':
          comparison = a.industry.compareTo(b.industry);
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'viewCount':
          comparison = a.viewCount.compareTo(b.viewCount);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedIndustry: _selectedIndustry,
        sortBy: _sortBy,
        isAscending: _isAscending,
        onApply: (industry, sortBy, isAscending) {
          setState(() {
            _selectedIndustry = industry;
            _sortBy = sortBy;
            _isAscending = isAscending;
          });
          _filterCareers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('Career Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterBottomSheet)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search careers, skills, or industries...',
              onChanged: (value) => setState(() => _filterCareers()),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              children: [
                _buildFilterChip('All', _selectedIndustry == 'All'),
                _buildFilterChip('Information Technology', _selectedIndustry == 'Information Technology'),
                _buildFilterChip('Healthcare', _selectedIndustry == 'Healthcare'),
                _buildFilterChip('Design', _selectedIndustry == 'Design'),
                _buildFilterChip('Agriculture', _selectedIndustry == 'Agriculture'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_filteredCareers.length} careers found', style: const TextStyle(color: Colors.black54)),
                TextButton.icon(
                  onPressed: _showFilterBottomSheet,
                  icon: const Icon(Icons.sort, size: 18),
                  label: Text(
                    _sortBy == 'title'
                        ? 'Name'
                        : _sortBy == 'industry'
                        ? 'Industry'
                        : _sortBy == 'rating'
                        ? 'Rating'
                        : 'Views',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredCareers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              itemCount: _filteredCareers.length,
              itemBuilder: (context, index) {
                final career = _filteredCareers[index];
                final animation = Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
                _animationController.forward();
                return FadeTransition(
                  opacity: animation,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - animation.value)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CareerCard(
                        career: career,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CareerDetailScreen(career: career)),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedIndustry = selected ? label : 'All');
          _filterCareers();
        },
        selectedColor: AppColors.primary.withOpacity(0.25),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        backgroundColor: AppColors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No careers found',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedIndustry = 'All');
              _filterCareers();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
