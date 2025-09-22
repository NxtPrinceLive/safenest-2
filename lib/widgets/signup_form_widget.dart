import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../widgets/role_selection_widget.dart';

class SignUpFormWidget extends StatefulWidget {
  final double buttonHeight;
  final double spacing;
  final Future<void> Function() onGoogleSignIn;
  final Future<void> Function() onMicrosoftSignIn;
  final Future<void> Function() onAppleSignIn;
  final Future<void> Function() onSlackSignIn;
  final Function(
    String email,
    String password,
    String displayName,
    UserRole role,
  )
  onSignUp;
  final VoidCallback onLoginLinkTap;

  const SignUpFormWidget({
    Key? key,
    required this.buttonHeight,
    required this.spacing,
    required this.onGoogleSignIn,
    required this.onMicrosoftSignIn,
    required this.onAppleSignIn,
    required this.onSlackSignIn,
    required this.onSignUp,
    required this.onLoginLinkTap,
  }) : super(key: key);

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget>
    with TickerProviderStateMixin {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController displayNameController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  UserRole _selectedRole = UserRole.child;

  // Social sign-in loading states
  bool _isGoogleLoading = false;
  bool _isMicrosoftLoading = false;
  bool _isAppleLoading = false;
  bool _isSlackLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    displayNameController = TextEditingController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        displayNameController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (!_acceptTerms) {
      _showSnackBar('Please accept the Terms of Service and Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate loading for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    widget.onSignUp(
      emailController.text,
      passwordController.text,
      displayNameController.text,
      _selectedRole,
    );
    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Create your account",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.spacing / 2),
            const Text(
              "Join SafeNest today",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.spacing * 2),

            // Email Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Montserrat',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.spacing),

            // Password Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  hintText: "Create a password",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Montserrat',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade400,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.spacing),

            // Display Name Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: displayNameController,
                style: const TextStyle(fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  hintText: "Enter your display name",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Montserrat',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.spacing),

            // Role Selection
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RoleSelectionWidget(
                selectedRole: _selectedRole,
                onRoleSelected: (UserRole role) {
                  setState(() {
                    _selectedRole = role;
                  });
                },
              ),
            ),
            SizedBox(height: widget.spacing / 2),

            // Terms and Conditions Checkbox
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontFamily: 'Montserrat',
                        ),
                        children: [
                          const TextSpan(text: "I agree to the "),
                          TextSpan(
                            text: "Terms of Service",
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse(
                                  'https://www.instagram.com/kxndari/',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                          ),
                          const TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse(
                                  'https://www.instagram.com/kxndari/',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.spacing),

            // Sign Up Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: _isLoading ? 0 : 2,
                  shadowColor: Colors.blue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
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
                    : const Text(
                        "Create account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
              ),
            ),
            SizedBox(height: widget.spacing * 1.5),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Or continue with",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            SizedBox(height: widget.spacing * 1.5),

            // Social Login Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: _isGoogleLoading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          )
                        : Icon(MdiIcons.google, size: 20, color: Colors.red),
                    label: Text(_isGoogleLoading ? "Loading..." : "Google"),
                    onPressed: _isGoogleLoading
                        ? null
                        : () async {
                            setState(() => _isGoogleLoading = true);
                            try {
                              await widget.onGoogleSignIn();
                            } finally {
                              if (mounted) {
                                setState(() => _isGoogleLoading = false);
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: widget.spacing / 2),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: _isMicrosoftLoading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade600,
                              ),
                            ),
                          )
                        : Icon(
                            MdiIcons.microsoftWindows,
                            size: 20,
                            color: Colors.blue.shade600,
                          ),
                    label: Text(
                      _isMicrosoftLoading ? "Loading..." : "Microsoft",
                    ),
                    onPressed: _isMicrosoftLoading
                        ? null
                        : () async {
                            setState(() => _isMicrosoftLoading = true);
                            try {
                              await widget.onMicrosoftSignIn();
                            } finally {
                              if (mounted) {
                                setState(() => _isMicrosoftLoading = false);
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.spacing / 2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: _isAppleLoading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : Icon(MdiIcons.apple, size: 20, color: Colors.black),
                    label: Text(_isAppleLoading ? "Loading..." : "Apple"),
                    onPressed: _isAppleLoading
                        ? null
                        : () async {
                            setState(() => _isAppleLoading = true);
                            try {
                              await widget.onAppleSignIn();
                            } finally {
                              if (mounted) {
                                setState(() => _isAppleLoading = false);
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: widget.spacing / 2),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: _isSlackLoading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.purple.shade600,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 16,
                            width: 16,
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/7/76/Slack_Icon.png',
                              color: Colors.purple.shade600,
                            ),
                          ),
                    label: Text(_isSlackLoading ? "Loading..." : "Slack"),
                    onPressed: _isSlackLoading
                        ? null
                        : () async {
                            setState(() => _isSlackLoading = true);
                            try {
                              await widget.onSlackSignIn();
                            } finally {
                              if (mounted) {
                                setState(() => _isSlackLoading = false);
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.spacing * 2),

            // Login Link
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    color: Colors.black54,
                  ),
                  text: "Already have an account? ",
                  children: [
                    TextSpan(
                      text: "Sign in",
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onLoginLinkTap,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: widget.spacing),

            // Footer Text
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "One account for SafeNest application across all Platforms.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontFamily: 'Montserrat',
                      ),
                      children: [
                        const TextSpan(
                          text:
                              "This site is protected by reCAPTCHA and the Google ",
                        ),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse(
                                'https://www.instagram.com/kxndari/',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse(
                                'https://www.instagram.com/kxndari/',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                        ),
                        const TextSpan(text: " apply."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
