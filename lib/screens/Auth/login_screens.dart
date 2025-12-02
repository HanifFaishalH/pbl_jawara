import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
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

  final Color jawaraColor = const Color(0xFF26547C);

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

  // 🔹 FUNGSI BARU: Menampilkan Popup Pending
  void _showPendingDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 50),
              const SizedBox(height: 10),
              const Text("Status Pending", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            message, // Pesan dari backend (Laravel)
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: jawaraColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(), // Tutup dialog
                child: const Text("OK, SAYA MENGERTI"),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- LOGIKA LOGIN ---
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // 1. Tampilkan Loading Indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final authService = AuthService();
        final result = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) Navigator.pop(context); // tutup loading

        if (result['success'] == true) {
          // --- KODE SUKSES (TIDAK BERUBAH) ---
          final data = result['data'];
          final user = data['user'];
          final prefs = await SharedPreferences.getInstance();

          final token = data['token'] ?? '';
          await prefs.setString('auth_token', token);
          await prefs.setInt('auth_user_id', user['user_id']);
          await prefs.setInt('auth_role_id', user['role_id']);
          await prefs.setString('user_nama_depan', user['user_nama_depan'] ?? 'User');
          await prefs.setString('user_nama_belakang', user['user_nama_belakang'] ?? '');

          AuthService.token = token;
          AuthService.userId = user['user_id'];
          AuthService.currentRoleId = user['role_id'];

          final namaUser = user['user_nama_depan'] ?? 'User';

          // Popup Sukses Login
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 60),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Login Berhasil!",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Selamat datang kembali, $namaUser",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(height: 8),
                      const Text("Mengalihkan ke Dashboard...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );

          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          Navigator.pop(context); 
          context.go('/dashboard');

        } else {
          // ❌ GAGAL LOGIN
          String message = result['message'] ?? 'Login gagal';
          
          // 🔥 DETEKSI STATUS PENDING 🔥
          // Kita cek apakah pesannya mengandung kata "Pending" atau "Status"
          // (Pastikan pesan ini sesuai dengan return dari Laravel AuthController)
          if (message.toLowerCase().contains('pending') || 
              message.toLowerCase().contains('status')) {
            
            _showPendingDialog(message); // TAMPILKAN POPUP

          } else {
            // Jika error lain (Password salah, dll), tampilkan SnackBar biasa
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red.shade600,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Login: ${e.toString()}"),
            backgroundColor: Colors.red.shade600,
          ),
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
    // ... UI Build tidak berubah ...
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