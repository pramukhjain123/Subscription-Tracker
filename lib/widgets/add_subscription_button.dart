import 'package:flutter/material.dart';
import '../screens/add_subscription_screen.dart';

class AddSubscriptionButton extends StatelessWidget {
  const AddSubscriptionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddSubscriptionScreen(),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Subscription'),
      backgroundColor: const Color(0xFF2196F3),
      foregroundColor: Colors.white,
    );
  }
} 