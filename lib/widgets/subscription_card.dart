import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onDelete;
  final Function(double)? onUpdateUsage;
  final bool isCompact;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onDelete,
    this.onUpdateUsage,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilDue = subscription.daysUntilDue;
    final isOverdue = subscription.isOverdue;
    final isDueSoon = subscription.isDueSoon;

    Color statusColor;
    String statusText;
    
    if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Overdue';
    } else if (isDueSoon) {
      statusColor = Colors.orange;
      statusText = 'Due Soon';
    } else {
      statusColor = Colors.green;
      statusText = 'Active';
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showUsageDialog(context),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.timer,
            label: 'Usage',
          ),
          SlidableAction(
            onPressed: (_) => _showDeleteDialog(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${subscription.price.toStringAsFixed(2)}/month',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (!isCompact) ...[
                  const SizedBox(height: 16),
                  
                  // Due Date Progress
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(subscription.dueDate)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isOverdue 
                          ? '${daysUntilDue.abs()} days overdue'
                          : '$daysUntilDue days left',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Progress Bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return LinearPercentIndicator(
                        width: constraints.maxWidth,
                        lineHeight: 6,
                        percent: _calculateProgressPercent(),
                        backgroundColor: Colors.grey[300],
                        progressColor: statusColor,
                        barRadius: const Radius.circular(3),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Usage Information
                  if (subscription.usageHours > 0) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Usage: ${subscription.usageHours.toStringAsFixed(1)} hours',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${subscription.hourlyRate.toStringAsFixed(2)}/hour',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    if (subscription.lastUsed != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last used: ${DateFormat('MMM dd').format(subscription.lastUsed!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showUsageDialog(context),
                          icon: const Icon(Icons.timer, size: 16),
                          label: const Text('Update Usage'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showCancelDialog(context),
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('Cancel Sub'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateProgressPercent() {
    // Calculate progress based on 30-day billing cycle
    const totalDays = 30;
    final daysLeft = subscription.daysUntilDue;
    
    if (daysLeft <= 0) return 1.0; // Overdue
    if (daysLeft >= totalDays) return 0.0; // Just started
    
    return 1.0 - (daysLeft / totalDays);
  }

  void _showUsageDialog(BuildContext context) {
    final controller = TextEditingController(
      text: subscription.usageHours.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How many hours did you use ${subscription.name}?'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Hours',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final hours = double.tryParse(controller.text) ?? 0.0;
              onUpdateUsage?.call(hours);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text('Are you sure you want to delete ${subscription.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel ${subscription.name}?'),
            const SizedBox(height: 16),
            const Text(
              'This will remove the subscription from your tracking list.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Sub'),
          ),
        ],
      ),
    );
  }
} 