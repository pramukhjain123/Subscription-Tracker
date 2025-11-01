import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/subscription_provider.dart';
import '../models/subscription.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SubscriptionProvider>();
    final total = sp.totalMonthlyCost;
    final dueSoon = sp.dueSoonSubscriptions.take(5).toList();
    final mostExpensive = [...sp.subscriptions]..sort((a,b)=>b.price.compareTo(a.price));
    final top5 = mostExpensive.take(5).toList();

    return CustomScrollView(
      key: const PageStorageKey('dashboard'),
      slivers: [
        const SliverAppBar(title: Text('Dashboard'), floating: true),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Monthly Spend',
                        value: '₹${total.toStringAsFixed(0)}',
                        icon: Icons.payments_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Active Subs',
                        value: sp.subscriptions.length.toString(),
                        icon: Icons.subscriptions_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: 'Daily Cost',
                  value: '₹${(total / 30).toStringAsFixed(0)}',
                  icon: Icons.calendar_view_day_rounded,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Cost Breakdown'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: _CostPie(top5: top5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Upcoming Renewals'),
                    const SizedBox(height: 8),
                    if (dueSoon.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('No upcoming renewals in the next 7 days'),
                      )
                    else ...dueSoon.map((s) => _UpcomingTile(sub: s)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CostPie extends StatelessWidget {
  const _CostPie({required this.top5});
  final List<Subscription> top5;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = top5.isEmpty
        ? [PieChartSectionData(value: 1, color: colors.primary.withOpacity(0.2), title: '')]
        : top5
            .asMap()
            .entries
            .map((e) => PieChartSectionData(
                  value: e.value.price,
                  color: _palette(colors)[e.key % _palette(colors).length],
                  title: '',
                  radius: 48,
                ))
            .toList();
    return PieChart(
      PieChartData(
        sections: items,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  List<Color> _palette(ColorScheme s) => [
        s.primary,
        s.tertiary,
        s.secondary,
        s.primaryContainer,
        s.secondaryContainer,
      ].map((c) => c.withOpacity(0.9)).toList();
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.sub});
  final Subscription sub;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: cs.primary.withOpacity(0.12), child: Icon(Icons.calendar_today, color: cs.primary)),
      title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('Due in ${sub.daysUntilDue} days'),
      trailing: FilledButton.tonal(
        onPressed: sub.id == null
            ? null
            : () async {
                // If paymentUrl exists, open it; otherwise mark as paid
                if (sub.paymentUrl != null && sub.paymentUrl!.isNotEmpty) {
                  final uri = Uri.tryParse(sub.paymentUrl!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid payment URL')),
                    );
                  }
                } else {
                  await context.read<SubscriptionProvider>().markAsPaid(sub.id!);
                  await context.read<SubscriptionProvider>().rescheduleNotifications();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as paid and rescheduled')),
                  );
                }
              },
        child: const Text('Pay'),
      ),
    );
  }
}
