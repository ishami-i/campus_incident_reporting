import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';

class ReportSummaryStudent extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final int resolvedCount;
  final int submittedCount;

  const ReportSummaryStudent({
    super.key,
    this.totalCount = 0,
    this.inProgressCount = 0,
    this.resolvedCount = 0,
    this.submittedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.background[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incident Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.text[950],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Total',
                  count: '$totalCount',
                  color: colors.primary[500]!,
                  textColor: colors.text[50]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'In Progress',
                  count: '$inProgressCount',
                  color: Colors.orange.shade700,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Resolved',
                  count: '$resolvedCount',
                  color: Colors.green.shade700,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Submitted',
                  count: '$submittedCount',
                  color: colors.secondary[500]!,
                  textColor: colors.text[50]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String count,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
