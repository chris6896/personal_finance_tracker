import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'database_helper.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red[400]!,
              Colors.red[600]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Header Section
                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_add,
                          size: 45,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start your financial journey with us',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Sign Up Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: ageController,
                          label: 'Age',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _handleSignUp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[600]!),
        ),
      ),
    );
  }

  void _handleSignUp(BuildContext context) async {
    // Validate inputs
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar(context, 'Please fill in all fields');
      return;
    }

    // Validate age
    final age = int.tryParse(ageController.text);
    if (age == null || age <= 0) {
      _showErrorSnackBar(context, 'Please enter a valid age');
      return;
    }

    // Validate email format
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(emailController.text)) {
      _showErrorSnackBar(context, 'Please enter a valid email address');
      return;
    }

    // Validate password match
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackBar(context, 'Passwords do not match');
      return;
    }

    // Validate password strength
    if (passwordController.text.length < 6) {
      _showErrorSnackBar(context, 'Password must be at least 6 characters long');
      return;
    }

    try {
      await DatabaseHelper().insertUser(
        nameController.text,
        age,
        emailController.text,
        passwordController.text,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
        ),
      );

      // Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Error creating account. Please try again.');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }
}