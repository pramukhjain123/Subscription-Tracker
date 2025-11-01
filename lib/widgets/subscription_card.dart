import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/subscription.dart';
import '../services/cancellation_service.dart';
import '../screens/add_subscription_screen.dart';

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
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${subscription.price.toStringAsFixed(2)}/month',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
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
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
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
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearPercentIndicator(
                          width: constraints.maxWidth,
                          lineHeight: 8,
                          percent: _calculateProgressPercent(),
                          backgroundColor: Colors.grey[200],
                          progressColor: statusColor,
                        ),
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
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddSubscriptionScreen(initial: subscription),
                            ),
                          );
                        },
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showUsageDialog(context),
                          icon: const Icon(Icons.timer_outlined, size: 18),
                          label: const Text('Update Usage'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openCancellationPage,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Cancel Online'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delete ${subscription.name}?',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('This action cannot be undone.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onDelete?.call();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.open_in_new_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cancel subscription online',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('We will open ${subscription.name}\'s cancellation page in a new tab.', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _openCancellationPage();
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open Page'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCancellationPage() async {
    final Uri? url = CancellationService.getCancellationUrl(subscription.name);
    if (url != null) {
      final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (launched) return;
    }
    final Uri search = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent('${subscription.name} cancel subscription')}');
    await launchUrl(search, mode: LaunchMode.externalApplication);
  }
} 