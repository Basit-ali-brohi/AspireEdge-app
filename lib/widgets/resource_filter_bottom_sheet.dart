import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class ResourceFilterBottomSheet extends StatefulWidget {
  final String selectedType;
  final String selectedCategory;
  final String sortBy;
  final bool isAscending;
  final Function(String type, String category, String sortBy, bool isAscending) onApply;

  const ResourceFilterBottomSheet({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.sortBy,
    required this.isAscending,
    required this.onApply,
  });

  @override
  State<ResourceFilterBottomSheet> createState() => _ResourceFilterBottomSheetState();
}

class _ResourceFilterBottomSheetState extends State<ResourceFilterBottomSheet> {
  late String _selectedType;
  late String _selectedCategory;
  late String _sortBy;
  late bool _isAscending;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedCategory = widget.selectedCategory;
    _sortBy = widget.sortBy;
    _isAscending = widget.isAscending;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort Resources',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = 'All';
                      _selectedCategory = 'All';
                      _sortBy = 'createdAt';
                      _isAscending = false;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          
          // Resource Type Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resource Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All', ...AppConstants.resourceTypes].map((type) {
                    final isSelected = _selectedType == type;
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'All',
                    'Technology',
                    'Career Advice',
                    'Interview Prep',
                    'Design',
                    'Career Tools',
                    'Education',
                    'Business',
                    'Science',
                    'Arts',
                  ].map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: AppColors.secondary.withOpacity(0.2),
                      checkmarkColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort By',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...['title', 'createdAt', 'rating', 'viewCount'].map((sortOption) {
                  final isSelected = _sortBy == sortOption;
                  return RadioListTile<String>(
                    title: Text(_getSortOptionName(sortOption)),
                    value: sortOption,
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sort Order
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Newest First'),
                    value: false,
                    groupValue: _isAscending,
                    onChanged: (value) {
                      setState(() {
                        _isAscending = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Oldest First'),
                    value: true,
                    groupValue: _isAscending,
                    onChanged: (value) {
                      setState(() {
                        _isAscending = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_selectedType, _selectedCategory, _sortBy, _isAscending);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortOptionName(String sortOption) {
    switch (sortOption) {
      case 'title':
        return 'Name';
      case 'createdAt':
        return 'Date';
      case 'rating':
        return 'Rating';
      case 'viewCount':
        return 'Popularity';
      default:
        return sortOption;
    }
  }
}
