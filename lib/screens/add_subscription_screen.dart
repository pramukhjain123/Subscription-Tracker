import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key, this.initial});
  final Subscription? initial;

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isAutoPay = false;
  bool _isLoading = false;

  // Category data
  static const List<String> _streamingAndEntertainment = [
    'Netflix',
    'Amazon Prime Video',
    'Disney+ Hotstar',
    'JioHotstar',
    'SonyLIV',
    'ZEE5',
    'Spotify',
    'Gaana',
    'JioSaavn',
    'Apple Music',
    'YouTube Premium',
    'Audible',
    'Kindle Unlimited',
  ];

  static const List<String> _subscriptionBoxes = [
    'Birchbox',
    'Fab Bag',
    'The Man Company',
    'LetsShave',
    'Ka-gazi',
    'The Whole Truth',
    'Blue Tokai Coffee Roasters',
    'Tea Box',
    'Snackible',
    'Dogsee Chew',
  ];

  static const List<String> _softwareAndSaaS = [
    'Microsoft 365',
    'Google Workspace',
    'Adobe Creative Cloud',
    'Tally',
    'Zoho Books',
    'QuickBooks',
    'Canva Pro',
    'Notion',
    'Slack',
    'Zoom',
    'Dropbox',
    'Evernote',
  ];

  static const List<String> _membershipsAndServices = [
    'Amazon Prime',
    'Flipkart Plus',
    'Zomato Gold',
    'Swiggy One',
    'Times Prime',
    'Cult.fit (Cultpass)',
    'Urban Company (UC Plus)',
    'BigBasket (bbstar)',
  ];

  static const List<String> _financialServices = [
    'LIC (Life Insurance Corporation of India)',
    'HDFC Life',
    'ICICI Prudential Life Insurance',
    'Bajaj Finserv',
    'HDFC Bank (for loans, credit cards)',
    'ICICI Bank (for loans, credit cards)',
    'State Bank of India (for loans, credit cards)',
    'Axis Bank (for loans, credit cards)',
    'Zerodha (for SIPs)',
    'Upstox (for SIPs)',
    'Groww (for SIPs)',
    'Paytm (for utility bills, SIPs)',
    'PhonePe (for utility bills, SIPs)',
    'Google Pay (for utility bills, SIPs)',
  ];

  static const List<String> _utilitiesAndBills = [
    'Airtel (Postpaid, Broadband)',
    'Jio (Postpaid, Fiber)',
    'Vodafone Idea (Vi) (Postpaid)',
    'Tata Power',
    'Adani Electricity',
    'BSES Rajdhani Power Limited',
    'Indraprastha Gas Limited (IGL)',
    'Mahanagar Gas Limited (MGL)',
    'Delhi Jal Board',
    'Brihanmumbai Municipal Corporation (for water tax)',
    'National Payments Corporation of India (for NACH mandates)',
  ];

  void _openSubscriptionPicker() {
    final List<String> tabTitles = [
      'Streaming & Entertainment',
      'Subscription Boxes',
      'Software & Productivity (SaaS)',
      'Memberships & Services',
      'Financial Services',
      'Utilities & Bills',
    ];

    final List<List<String>> tabData = [
      _streamingAndEntertainment,
      _subscriptionBoxes,
      _softwareAndSaaS,
      _membershipsAndServices,
      _financialServices,
      _utilitiesAndBills,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DefaultTabController(
          length: tabTitles.length,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Select Subscription',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  TabBar(
                    isScrollable: true,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    tabs: tabTitles.map((t) => Tab(text: t)).toList(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: TabBarView(
                      children: List.generate(tabTitles.length, (index) {
                        return _CategoryTab(
                          items: tabData[index],
                          onSelected: (value) {
                            _nameController.text = value;
                            Navigator.of(ctx).pop();
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final s = widget.initial!;
      _nameController.text = s.name;
      _priceController.text = s.price.toStringAsFixed(0);
      _selectedDate = s.dueDate;
      _isAutoPay = s.isAutoPay;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final subscription = Subscription(
        id: widget.initial?.id,
        userId: widget.initial?.userId ?? 'user123', // TODO: Replace with actual user ID
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        dueDate: _selectedDate,
        isAutoPay: _isAutoPay,
      );

      if (widget.initial == null) {
        await context.read<SubscriptionProvider>().addSubscription(subscription);
      } else {
        await context.read<SubscriptionProvider>().updateSubscription(subscription.id!, subscription);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initial == null ? 'Subscription added successfully!' : 'Subscription updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscription'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subscription Name (Searchable Dropdown)
              TextFormField(
                controller: _nameController,
                readOnly: true,
                onTap: _openSubscriptionPicker,
                decoration: const InputDecoration(
                  labelText: 'Subscription Name',
                  hintText: 'Search or pick from categories',
                  prefixIcon: Icon(Icons.subscriptions_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select a subscription';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Price (₹)',
                  hintText: 'e.g., 499',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Due Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Auto Pay Toggle
              SwitchListTile(
                title: const Text('Auto Pay'),
                subtitle: const Text('Automatically pay this subscription'),
                value: _isAutoPay,
                onChanged: (value) {
                  setState(() {
                    _isAutoPay = value;
                  });
                },
                secondary: const Icon(Icons.payment),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Add Subscription',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Usage Tracking',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'After adding your subscription, you can track your usage by tapping the "Update Usage" button on each subscription card.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

class _CategoryTab extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _CategoryTab({
    required this.items,
    required this.onSelected,
  });

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filtered = _query.isEmpty
        ? widget.items
        : widget.items
            .where((e) => e.toLowerCase().contains(_query))
            .toList(growable: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search services',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, idx) {
              final String value = filtered[idx];
              return ListTile(
                title: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => widget.onSelected(value),
              );
            },
          ),
        ),
      ],
    );
  }
}