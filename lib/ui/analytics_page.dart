import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/section_header.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SubscriptionProvider>();
    final totals = sp.subscriptions.map((s) => s.price).toList();

    return CustomScrollView(
      key: const PageStorageKey('analytics'),
      slivers: [
        const SliverAppBar(title: Text('Analytics'), floating: true),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverList.list(children: const [
            _TrendCard(),
            SizedBox(height: 12),
            _CategoryBarsCard(),
          ]),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Monthly Spend Trend'),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      spots: const [
                        FlSpot(0, 200),
                        FlSpot(1, 350),
                        FlSpot(2, 260),
                        FlSpot(3, 420),
                        FlSpot(4, 390),
                        FlSpot(5, 480),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBarsCard extends StatelessWidget {
  const _CategoryBarsCard();
  @override
  Widget build(BuildContext context) {
    final barColor = Theme.of(context).colorScheme.secondary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Category Breakdown'),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 400)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 320)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 210)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 160)]),
                  ],
                  barTouchData: BarTouchData(enabled: false),
                ),
                swapAnimationDuration: const Duration(milliseconds: 300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
