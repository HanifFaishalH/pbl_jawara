import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. WAJIB IMPORT INI
import '../../widgets/auth/login_header.dart';
import '../../widgets/auth/login_welcome.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/login_divider.dart';
import '../../widgets/auth/login_google_button.dart';
import '../../widgets/auth/login_register_link.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = AuthService();
        // Asumsi: result berisi Map dari JSON response Laravel
        final result = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        // 2. LOGIKA PENYIMPANAN TOKEN (SANGAT PENTING)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Pastikan key 'token' sesuai dengan response JSON dari Laravel Anda
        // Biasanya: { "token": "...", "user": {...} }
        String token = result['token'] ?? ''; 
        await prefs.setString('token', token);
        
        // Simpan juga nama user jika perlu untuk ditampilkan di dashboard nanti
        String namaUser = result['user']['user_nama_depan'] ?? 'User';
        await prefs.setString('user_nama', namaUser);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login berhasil, selamat datang $namaUser'),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/dashboard');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Login: ${e.toString()}")),
        );
      }
    }
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign In dalam pengembangan')),
    );
  }

  void _handleDaftar() {
    Future.delayed(const Duration(milliseconds: 200), () {
      context.go('/register');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: 40),
                      const LoginWelcome(),
                      const SizedBox(height: 40),
                      LoginForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        onLogin: _handleLogin,
                      ),
                      const SizedBox(height: 32),
                      const LoginDivider(),
                      const SizedBox(height: 24),
                      LoginGoogleButton(onTap: _handleGoogleLogin),
                      const SizedBox(height: 24),
                      LoginRegisterLink(onTap: _handleDaftar),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}