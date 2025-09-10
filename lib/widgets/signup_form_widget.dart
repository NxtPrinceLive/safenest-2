import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpFormWidget extends StatefulWidget {
  final double buttonHeight;
  final double spacing;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onMicrosoftSignIn;
  final VoidCallback onAppleSignIn;
  final VoidCallback onSlackSignIn;
  final Function(String email, String password) onSignUp;
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

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Sign up to continue",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: widget.spacing),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter your email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            suffixIcon: const Icon(Icons.email),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
        SizedBox(height: widget.spacing / 2),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter your password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            suffixIcon: const Icon(Icons.lock_outline),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
        SizedBox(height: widget.spacing / 2),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontFamily: 'Montserrat',
            ),
            children: [
              const TextSpan(text: "By signing up, I accept the Safenest "),
              TextSpan(
                text: "Cloud Terms of Service",
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final url = Uri.parse('https://www.instagram.com/kxndari/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
              ),
              const TextSpan(text: " and acknowledge the "),
              TextSpan(
                text: "Privacy Policy.",
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final url = Uri.parse('https://www.instagram.com/kxndari/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
              ),
            ],
          ),
        ),
        SizedBox(height: widget.spacing),
        ElevatedButton(
          onPressed: () =>
              widget.onSignUp(emailController.text, passwordController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, widget.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            "Sign up",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        SizedBox(height: widget.spacing),
        const Center(
          child: Text("Or continue with:", style: TextStyle(fontSize: 14)),
        ),
        SizedBox(height: widget.spacing),
        OutlinedButton.icon(
          icon: Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
          label: const Text("Google"),
          onPressed: widget.onGoogleSignIn,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: Size(double.infinity, widget.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: widget.spacing / 2),
        OutlinedButton.icon(
          icon: Icon(Icons.window, size: 24, color: Colors.blue),
          label: const Text("Microsoft"),
          onPressed: widget.onMicrosoftSignIn,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: Size(double.infinity, widget.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: widget.spacing / 2),
        OutlinedButton.icon(
          icon: Icon(Icons.apple, size: 24, color: Colors.black),
          label: const Text("Apple"),
          onPressed: widget.onAppleSignIn,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: Size(double.infinity, widget.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: widget.spacing / 2),
        OutlinedButton.icon(
          icon: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/7/76/Slack_Icon.png',
            height: 20,
            width: 20,
          ),
          label: const Text("Slack"),
          onPressed: widget.onSlackSignIn,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: Size(double.infinity, widget.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: widget.spacing),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontFamily: 'Montserrat',
              ),
              text: "Already have an Safenest account? ",
              children: [
                TextSpan(
                  text: "Log in",
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onLoginLinkTap,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: widget.spacing * 2),
        Center(
          child: Column(
            children: [
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/7/7a/Atlassian_logo.svg',
                height: 30,
              ),
              const SizedBox(height: 8),
              const Text(
                "One account for Safenest application across all the Platforms.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  children: [
                    const TextSpan(
                      text:
                          "This site is protected by reCAPTCHA and the Google ",
                    ),
                    TextSpan(
                      text: "Privacy Policy",
                      style: const TextStyle(color: Colors.blue),
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
                      style: const TextStyle(color: Colors.blue),
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
    );
  }
}
