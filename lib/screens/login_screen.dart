import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; // user cancelled login

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken, // <-- valid now
    );

    await _auth.signInWithCredential(credential);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/home");
  } catch (e) {
    debugPrint("Google Sign-In Error: $e");
  }
}


  // ---------------- Phone OTP ----------------
  Future<void> signInWithPhone() async {
    TextEditingController phoneController = TextEditingController();
    TextEditingController otpController = TextEditingController();

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
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, "/home");
                },
                verificationFailed: (FirebaseAuthException e) {
                  debugPrint("Phone Verification Failed: ${e.message}");
                },
                codeSent: (String verificationId, int? resendToken) {
                  // Ask OTP after code sent
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Enter OTP"),
                      content: TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: "Enter OTP"),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Verify"),
                          onPressed: () async {
                            final credential = PhoneAuthProvider.credential(
                              verificationId: verificationId,
                              smsCode: otpController.text,
                            );
                            await _auth.signInWithCredential(credential);
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, "/home");
                          },
                        ),
                      ],
                    ),
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SafeNest Login"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text("Sign in with Email"),
                onPressed: signInWithEmail,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text("Sign in with Google"),
                onPressed: signInWithGoogle,
              ),
              const SizedBox(height: 16),
              SignInWithAppleButton(
                onPressed: signInWithApple,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text("Sign in with Phone (OTP)"),
                onPressed: signInWithPhone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
