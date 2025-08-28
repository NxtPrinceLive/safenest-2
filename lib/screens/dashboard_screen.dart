import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/bottom_navbar.dart';
import 'location_screen.dart';
import 'controls_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardHome(),
    LocationScreen(),
    ControlsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SafeNest Dashboard"),
        backgroundColor: Colors.teal,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CustomCard(
          title: "Child: Priya",
          subtitle: "Last Online: 2 mins ago",
          icon: Icons.person,
        ),
        const CustomCard(
          title: "Last Location",
          subtitle: "Lat: 28.61, Lng: 77.20",
          icon: Icons.location_on,
        ),
        const CustomCard(
          title: "Screen Time",
          subtitle: "2 hrs today",
          icon: Icons.timer,
        ),
        const SizedBox(height: 20),

        // Quick Controls Section
        Text(
          "Quick Controls",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quickControlButton(Icons.lock, "Lock Apps"),
            _quickControlButton(Icons.language, "Block Sites"),
            _quickControlButton(Icons.notifications, "Alert Child"),
          ],
        ),
      ],
    );
  }

  // Reusable quick control button
  Widget _quickControlButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.teal,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
