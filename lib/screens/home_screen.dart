import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/subscription_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/subscription_card.dart';
import '../widgets/add_subscription_button.dart';
import '../widgets/overview_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load subscriptions after the widget is built and auth state is determined
      _loadSubscriptionsIfAuthenticated();
    });
  }

  void _loadSubscriptionsIfAuthenticated() {
    final authProvider = context.read<AuthProvider>();
    print('HomeScreen: Checking if should load subscriptions - Auth: ${authProvider.isAuthenticated}');
    if (authProvider.isAuthenticated) {
      print('HomeScreen: Loading subscriptions...');
      context.read<SubscriptionProvider>().loadSubscriptions();
    } else {
      print('HomeScreen: Not authenticated, skipping subscription load');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to auth state changes and load subscriptions when authenticated
    final authProvider = context.read<AuthProvider>();
    print('HomeScreen: didChangeDependencies - Auth: ${authProvider.isAuthenticated}');
    if (authProvider.isAuthenticated) {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      print('HomeScreen: Auth confirmed, checking subscription state - Count: ${subscriptionProvider.subscriptions.length}, Loading: ${subscriptionProvider.isLoading}');
      if (subscriptionProvider.subscriptions.isEmpty && !subscriptionProvider.isLoading) {
        print('HomeScreen: Loading subscriptions from didChangeDependencies');
        subscriptionProvider.loadSubscriptions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Subscription Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              print('HomeScreen: Manual refresh triggered');
              // First refresh auth state, then load subscriptions
              context.read<AuthProvider>().refreshAuthState().then((_) {
                context.read<SubscriptionProvider>().loadSubscriptions();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, SubscriptionProvider>(
        builder: (context, authProvider, subscriptionProvider, child) {
          // Debug info
          print('Auth state: ${authProvider.isAuthenticated}, User: ${authProvider.currentUser}');
          print('Subscriptions count: ${subscriptionProvider.subscriptions.length}, Loading: ${subscriptionProvider.isLoading}, Error: ${subscriptionProvider.error}');
          
          // If not authenticated, show login prompt
          if (!authProvider.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to view subscriptions',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          if (subscriptionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (subscriptionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${subscriptionProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      subscriptionProvider.clearError();
                      subscriptionProvider.loadSubscriptions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: subscriptionProvider.loadSubscriptions,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Cards
                        Row(
                          children: [
                            Expanded(
                              child: OverviewCard(
                                title: 'Total Cost',
                                value: '₹${subscriptionProvider.totalMonthlyCost.toStringAsFixed(2)}',
                                icon: Icons.attach_money,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OverviewCard(
                                title: 'Due Soon',
                                value: subscriptionProvider.dueSoonSubscriptions.length.toString(),
                                icon: Icons.warning,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OverviewCard(
                                title: 'Overdue',
                                value: subscriptionProvider.overdueSubscriptions.length.toString(),
                                icon: Icons.error,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OverviewCard(
                                title: 'Total Subs',
                                value: subscriptionProvider.subscriptions.length.toString(),
                                icon: Icons.list,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Due Soon Section
                        if (subscriptionProvider.dueSoonSubscriptions.isNotEmpty) ...[
                          const Text(
                            'Due Soon',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: subscriptionProvider.dueSoonSubscriptions.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 200,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: SubscriptionCard(
                                    subscription: subscriptionProvider.dueSoonSubscriptions[index],
                                    isCompact: true,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // All Subscriptions
                        const Text(
                          'All Subscriptions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                
                // Subscription List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final subscription = subscriptionProvider.sortedSubscriptions[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: SubscriptionCard(
                                  subscription: subscription,
                                  onDelete: () => subscriptionProvider.deleteSubscription(subscription.id!),
                                  onUpdateUsage: (hours) => subscriptionProvider.updateUsage(subscription.id!, hours),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: subscriptionProvider.sortedSubscriptions.length,
                      ),
                    ),
                  ),
                ),
                
                // Empty State
                if (subscriptionProvider.subscriptions.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.subscriptions_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No subscriptions yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first subscription to get started',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: const AddSubscriptionButton(),
    );
  }
} 