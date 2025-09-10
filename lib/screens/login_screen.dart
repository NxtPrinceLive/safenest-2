import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../widgets/signup_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        accessToken: googleAuth.accessToken, // <-- valid now
      );

      await _auth.signInWithCredential(credential);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, "/home");
        });
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
    }
  }

  // ---------------- Phone OTP ----------------
  Future<void> signInWithPhone() async {
    TextEditingController phoneController = TextEditingController();

    // Ask phone number first
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
              Navigator.pop(context); // close dialog

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? "Verification failed"),
                      ),
                    );
                  }
                },
                codeSent: (String verificationId, int? resendToken) {
                  // Navigate to OTP screen
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
  Future<void> signInWithEmail() async {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign in with Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Sign In"),
            onPressed: () async {
              try {
                await _auth.signInWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context); // close dialog
                    Navigator.pushReplacementNamed(context, "/home");
                  });
                }
              } catch (e) {
                debugPrint("Email Sign-In Error: $e");
                // Optionally show error dialog
              }
            },
          ),
        ],
      ),
    );
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
    }
  }

  Widget buildSignUpForm(
    BuildContext context,
    double buttonHeight,
    double spacing,
  ) {
    return SignUpFormWidget(
      buttonHeight: buttonHeight,
      spacing: spacing,
      onGoogleSignIn: () async {
        await signInWithGoogle();
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, "/home");
          });
        }
      },
      onMicrosoftSignIn: () {
        // TODO: Implement Microsoft sign-in navigation
        Navigator.pushReplacementNamed(context, "/home");
      },
      onAppleSignIn: () async {
        await signInWithApple();
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, "/home");
          });
        }
      },
      onSlackSignIn: () {
        // TODO: Implement Slack sign-in navigation
        Navigator.pushReplacementNamed(context, "/home");
      },
      onSignUp: (String email, String password) async {
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sign-up failed: ${e.toString()}")),
            );
          }
        }
      },
      onLoginLinkTap: () {
        // TODO: Implement login link navigation
        Navigator.pushReplacementNamed(context, "/login");
      },
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
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      height: logoSize,
                      width: logoSize,
                    ),
                    SizedBox(height: spacing * 3),
                    // Sign-up form widget
                    buildSignUpForm(context, buttonHeight, spacing),
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
