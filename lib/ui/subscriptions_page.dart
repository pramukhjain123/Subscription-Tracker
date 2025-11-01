import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_card.dart';
import '../widgets/section_header.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SubscriptionProvider>();
    final items = sp.sortedSubscriptions;

    return CustomScrollView(
      key: const PageStorageKey('subscriptions'),
      slivers: [
        const SliverAppBar(title: Text('Subscriptions'), floating: true),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(child: SectionHeader(title: 'All Subscriptions')),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No subscriptions. Tap Add to create one.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final sub = items[i];
                return SubscriptionCard(
                  subscription: sub,
                  onDelete: () async {
                    if (sub.id != null) {
                      await context.read<SubscriptionProvider>().deleteSubscription(sub.id!);
                    }
                  },
                  onUpdateUsage: (hours) async {
                    if (sub.id != null) {
                      await context.read<SubscriptionProvider>().updateUsage(sub.id!, hours);
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
