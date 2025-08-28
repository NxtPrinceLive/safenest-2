import 'package:flutter/material.dart';

class ControlsScreen extends StatelessWidget {
  const ControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Controls"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔒 App Lock Section
          _buildControlCard(
            context,
            title: "Lock Apps",
            description: "Restrict child from opening specific apps instantly.",
            icon: Icons.lock,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Lock Apps feature coming soon!")),
              );
            },
          ),

          // 🌐 Block Websites Section
          _buildControlCard(
            context,
            title: "Block Websites",
            description: "Block unsafe or distracting websites.",
            icon: Icons.language,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Block Websites feature coming soon!")),
              );
            },
          ),

          // 🔔 Alert Child Section
          _buildControlCard(
            context,
            title: "Send Alert",
            description: "Send instant alert notification to your child’s device.",
            icon: Icons.notifications,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alert sent to child device!")),
              );
            },
          ),
        ],
      ),
    );
  }

  // Reusable Control Card Widget
  Widget _buildControlCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          child: const Text("Activate"),
        ),
      ),
    );
  }
}
