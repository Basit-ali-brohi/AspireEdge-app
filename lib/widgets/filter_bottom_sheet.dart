import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final String selectedIndustry;
  final String sortBy;
  final bool isAscending;
  final Function(String industry, String sortBy, bool isAscending) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedIndustry,
    required this.sortBy,
    required this.isAscending,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedIndustry;
  late String _sortBy;
  late bool _isAscending;

  @override
  void initState() {
    super.initState();
    _selectedIndustry = widget.selectedIndustry;
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
                  'Filter & Sort',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndustry = 'All';
                      _sortBy = 'title';
                      _isAscending = true;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          
          // Industry Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Industry',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All', ...AppConstants.industries].map((industry) {
                    final isSelected = _selectedIndustry == industry;
                    return FilterChip(
                      label: Text(industry),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedIndustry = industry;
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
                ...['title', 'industry', 'rating', 'viewCount'].map((sortOption) {
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
                    title: const Text('Ascending'),
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
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Descending'),
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
                  widget.onApply(_selectedIndustry, _sortBy, _isAscending);
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
      case 'industry':
        return 'Industry';
      case 'rating':
        return 'Rating';
      case 'viewCount':
        return 'Popularity';
      default:
        return sortOption;
    }
  }
}
