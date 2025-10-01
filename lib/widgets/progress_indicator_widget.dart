import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final String? label;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Progress Text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label ?? 'Progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$currentStep of $totalSteps',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Percentage
        Text(
          '${(progress * 100).round()}% Complete',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
