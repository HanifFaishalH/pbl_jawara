import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      // Form container
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            // Email input
            const SizedBox(height: 8),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Masukkan email disini'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            // Password input
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: _inputDecoration('Masukkan password disini').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),

            // Login button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Style decoration ntar sesuain sama tema e
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF26547C)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
