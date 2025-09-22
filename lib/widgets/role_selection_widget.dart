import 'package:flutter/material.dart';
import '../models/user_model.dart';

class RoleSelectionWidget extends StatefulWidget {
  final UserRole? selectedRole;
  final Function(UserRole) onRoleSelected;
  final bool isLoading;

  const RoleSelectionWidget({
    Key? key,
    this.selectedRole,
    required this.onRoleSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<RoleSelectionWidget> createState() => _RoleSelectionWidgetState();
}

class _RoleSelectionWidgetState extends State<RoleSelectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Choose your role",
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select how you'll be using SafeNest",
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection Cards
              Row(
                children: [
                  // Parent Card
                  Expanded(
                    child: _buildRoleCard(
                      context,
                      role: UserRole.parent,
                      title: "Parent",
                      description: "Monitor and protect your children",
                      icon: Icons.shield,
                      features: [
                        "Monitor child's location",
                        "Set app time limits",
                        "Block inappropriate content",
                        "Receive safety alerts",
                        "View activity reports",
                      ],
                      isSelected: widget.selectedRole == UserRole.parent,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  // Child Card
                  Expanded(
                    child: _buildRoleCard(
                      context,
                      role: UserRole.child,
                      title: "Child",
                      description: "Stay safe with parental guidance",
                      icon: Icons.person,
                      features: [
                        "Share location with parents",
                        "Receive safety alerts",
                        "Follow parent-set rules",
                        "Contact parents easily",
                        "View approved content only",
                      ],
                      isSelected: widget.selectedRole == UserRole.child,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 50 : 60,
                child: ElevatedButton(
                  onPressed: widget.isLoading || widget.selectedRole == null
                      ? null
                      : () => widget.onRoleSelected(widget.selectedRole!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.blue.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          "Continue as ${widget.selectedRole == UserRole.parent ? 'Parent' : 'Child'}",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required List<String> features,
    required bool isSelected,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: widget.isLoading ? null : () => widget.onRoleSelected(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.blue.shade600
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: isSelected ? Colors.blue.shade700 : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Features List
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: isSelected
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                          color: Colors.black54,
                        ),
                      ),
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
