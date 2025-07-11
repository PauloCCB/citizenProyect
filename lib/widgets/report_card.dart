import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                _buildPriorityChip(report.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(
                  '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                const Text(
                  'Ubicación',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
            if (report.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: report.tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color backgroundColor;
    Color textColor;

    switch (priority.toLowerCase()) {
      case 'alta':
      case 'crítica':
        backgroundColor = AppColors.redLight;
        textColor = AppColors.red;
        break;
      case 'media':
        backgroundColor = AppColors.orangeLight;
        textColor = AppColors.orange;
        break;
      case 'baja':
        backgroundColor = AppColors.greenLight;
        textColor = AppColors.green;
        break;
      default:
        backgroundColor = AppColors.lightGrey;
        textColor = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.blue,
        ),
      ),
    );
  }
} 