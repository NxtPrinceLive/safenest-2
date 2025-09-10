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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30, width: 30),
            const SizedBox(width: 8),
            const Text("SafeNest"),
          ],
        ),
        actions: [
          // Parent's name/profile pic
          Row(
            children: [
              const Text("Hi, Priyanshu", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Notifications bell
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Cards grid
          Expanded(
            child: GridView.count(
              crossAxisCount: isSmallScreen ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
              children: const [
                CustomCard(
                  title: "Child : Pihu",
                  subtitle: "Last Online: 2 mins ago",
                  icon: Icons.person,
                ),
                CustomCard(
                  title: "Last Location",
                  subtitle: "Lat: 28.61, Lng: 77.20",
                  icon: Icons.location_on,
                ),
                CustomCard(
                  title: "Screen Time",
                  subtitle: "2 hrs today",
                  icon: Icons.timer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Controls Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Quick Controls",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 10),

          // Responsive buttons row or column
          isSmallScreen
              ? Column(
                  children: [
                    _quickControlButton(Icons.lock, "Lock Apps"),
                    const SizedBox(height: 12),
                    _quickControlButton(Icons.language, "Block Sites"),
                    const SizedBox(height: 12),
                    _quickControlButton(Icons.notifications, "Alert Child"),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quickControlButton(Icons.lock, "Lock Apps"),
                    _quickControlButton(Icons.language, "Block Sites"),
                    _quickControlButton(Icons.notifications, "Alert Child"),
                  ],
                ),
        ],
      ),
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
