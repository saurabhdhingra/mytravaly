import 'package:flutter/material.dart';
import 'package:mytravaly/data/provider/auth.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    final authNotifier = Provider.of<AuthNotifier>(context);
    final bool isLoading = authNotifier.isLoading;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
    
              SizedBox(
                width: width - 64,
                child: FittedBox(
                  child: Text(
                    'Welcome to MyTravaly',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign In to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: screenSize.height * 0.08),

              _buildStandardLoginForm(context, authNotifier, isLoading),

              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 30),

              _buildGoogleSignInButton(authNotifier, isLoading),

              const SizedBox(height: 40),
              const Text(
                'NOTE: Both login options use the same function to simulate sign-in/registration, fulfilling the device registration API requirement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardLoginForm(
    BuildContext context,
    AuthNotifier authNotifier,
    bool isLoading,
  ) {
    return Column(
      children: [

        TextFormField(
          controller: _emailController,
          enabled: !isLoading,
          decoration: _inputDecoration(
            hint: 'Enter anything (Email/Username)',
            icon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _passwordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: _inputDecoration(
            hint: 'Enter anything (Password)',
            icon: Icons.lock_outline,
          ),
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () {
                    authNotifier.signInAndRegister();
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child:
                isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(AuthNotifier authNotifier, bool isLoading) {
    return OutlinedButton.icon(
      onPressed:
          isLoading
              ? null
              : () =>
                  authNotifier
                      .signInAndRegister(), // Trigger device registration/login for Google
      icon: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/512px-Google_%22G%22_logo.svg.png',
        height: 24.0,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.login, color: Colors.blue), // Fallback icon
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Text(
          isLoading ? 'Registering Device...' : 'Sign In with Google',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade400),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.red.shade400),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 20.0,
      ),
    );
  }
}
