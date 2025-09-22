import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../widgets/signup_form_widget.dart';
import '../widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Animation controllers
  late AnimationController _formSwitchController;
  late Animation<double> _formSwitchAnimation;

  bool _isLoginMode = false; // false = signup, true = login

  @override
  void initState() {
    super.initState();

    _formSwitchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _formSwitchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formSwitchController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _formSwitchController.dispose();
    super.dispose();
  }

  void _toggleFormMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      if (_isLoginMode) {
        _formSwitchController.forward();
      } else {
        _formSwitchController.reverse();
      }
    });
  }

  // ---------------- Google Sign In ----------------
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // user cancelled login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await _auth.signInWithCredential(credential);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, "/home");
        });
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      _showErrorSnackBar("Google sign-in failed");
    }
  }

  // ---------------- Phone OTP ----------------
  Future<void> signInWithPhone() async {
    TextEditingController phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Phone Number"),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "+91XXXXXXXXXX"),
        ),
        actions: [
          TextButton(
            child: const Text("Send OTP"),
            onPressed: () async {
              Navigator.pop(context);

              await _auth.verifyPhoneNumber(
                phoneNumber: phoneController.text,
                verificationCompleted: (PhoneAuthCredential credential) async {
                  await _auth.signInWithCredential(credential);
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, "/home");
                    });
                  }
                },
                verificationFailed: (FirebaseAuthException e) {
                  if (mounted) {
                    _showErrorSnackBar(e.message ?? "Verification failed");
                  }
                },
                codeSent: (String verificationId, int? resendToken) {
                  Navigator.pushNamed(
                    context,
                    '/otp',
                    arguments: verificationId,
                  );
                },
                codeAutoRetrievalTimeout: (String verificationId) {},
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- Email Sign In ----------------
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, "/home");
        });
      }
    } catch (e) {
      debugPrint("Email Sign-In Error: $e");
      _showErrorSnackBar("Invalid email or password");
    }
  }

  // ---------------- Apple Sign In ----------------
  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, "/home");
        });
      }
    } catch (e) {
      debugPrint("Apple Sign-In Error: $e");
      _showErrorSnackBar("Apple sign-in failed");
    }
  }

  // ---------------- Email Sign Up ----------------
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, "/home");
        });
      }
    } catch (e) {
      debugPrint("Sign-Up Error: $e");
      _showErrorSnackBar("Sign-up failed: ${e.toString()}");
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double logoSize = constraints.maxHeight * 0.08;
            double horizontalPadding = isSmallScreen ? 24.0 : 48.0;
            double buttonHeight = isSmallScreen ? 50.0 : 60.0;
            double spacing = isSmallScreen ? 16.0 : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: logoSize,
                      width: logoSize,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: spacing * 3),

                    // Animated form container
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOutCubic,
                                      ),
                                    ),
                                child: child,
                              ),
                            );
                          },
                      child: _isLoginMode
                          ? LoginFormWidget(
                              key: const ValueKey('login'),
                              buttonHeight: buttonHeight,
                              spacing: spacing,
                              onGoogleSignIn: signInWithGoogle,
                              onMicrosoftSignIn: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  "/home",
                                );
                              },
                              onAppleSignIn: signInWithApple,
                              onSlackSignIn: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  "/home",
                                );
                              },
                              onLogin: signInWithEmail,
                              onSignUpLinkTap: _toggleFormMode,
                            )
                          : SignUpFormWidget(
                              key: const ValueKey('signup'),
                              buttonHeight: buttonHeight,
                              spacing: spacing,
                              onGoogleSignIn: signInWithGoogle,
                              onMicrosoftSignIn: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  "/home",
                                );
                              },
                              onAppleSignIn: signInWithApple,
                              onSlackSignIn: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  "/home",
                                );
                              },
                              onSignUp: signUpWithEmail,
                              onLoginLinkTap: _toggleFormMode,
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
