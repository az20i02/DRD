import 'package:flutter/material.dart';
import '../models/report_model.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final bool showWorkerActions;
  final Function(String) onStatusChanged;

  const ReportCard({
    super.key,
    required this.report,
    required this.showWorkerActions,
    required this.onStatusChanged,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/report_detail',
            arguments: report,
                      );
                    },
        child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                  Expanded(
                    child: Text(
                      report.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(report.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          report.status,
                          style: TextStyle(
                            color: _getStatusColor(report.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 8),
                  Text(
                'Reported on ${_formatDate(report.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
              if (showWorkerActions && report.status == 'pending') ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => onStatusChanged('rejected'),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => onStatusChanged('in_progress'),
                      child: const Text('Accept'),
                    ),
                  ],
                    ),
                  ],
                ],
              ),
        ),
      ),
    );
  }
} 