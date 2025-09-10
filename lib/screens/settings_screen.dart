// settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    double horizontalPadding = isSmallScreen ? 24.0 : 48.0;
    double spacing = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: spacing,
        ),
        child: Center(
          child: Text(
            "Settings Coming Soon",
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
}
