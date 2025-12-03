import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan import di bawah ini sesuai dengan struktur folder Anda
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

  // Warna utama aplikasi
  final Color jawaraColor = const Color(0xFF26547C);

  // Animasi
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // 1. POPUP SUKSES (HIJAU)
  // ==========================================================
  // Note: Fungsi ini mengembalikan Future, tapi kita TIDAK akan meng-await-nya
  // saat pemanggilan agar timer bisa berjalan.
  Future<void> _showSuccessDialog(String namaUser) {
    return showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa klik luar untuk tutup
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.green.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 60),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Login Berhasil!",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  "Selamat datang kembali, $namaUser",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(height: 8),
                const Text("Mengalihkan ke Dashboard...",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // 2. POPUP PENDING (ORANYE)
  // ==========================================================
  void _showPendingDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.access_time_filled,
                      color: Colors.orange.shade600, size: 60),
                ),
                const SizedBox(height: 20),
                const Text("Status Pending",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: jawaraColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK, SAYA MENGERTI"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // 3. POPUP GAGAL (MERAH)
  // ==========================================================
  void _showFailureDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.cancel,
                      color: Colors.red.shade600, size: 60),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("COBA LAGI"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // LOGIKA LOGIN UTAMA (YANG DIPERBAIKI)
  // ==========================================================
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

        // 2. Tutup Loading Indicator (PENTING: dilakukan sebelum menampilkan popup hasil)
        if (mounted) Navigator.pop(context);

        if (result['success'] == true) {
          // --- ✅ KODE SUKSES ---
          final data = result['data'];
          final user = data['user'];
          final prefs = await SharedPreferences.getInstance();

          // Simpan data ke SharedPreferences
          final token = data['token'] ?? '';
          await prefs.setString('auth_token', token);
          await prefs.setInt('auth_user_id', user['user_id']);
          await prefs.setInt('auth_role_id', user['role_id']);
          await prefs.setString(
              'user_nama_depan', user['user_nama_depan'] ?? 'User');
          await prefs.setString(
              'user_nama_belakang', user['user_nama_belakang'] ?? '');

          // Update Static Var di AuthService
          AuthService.token = token;
          AuthService.userId = user['user_id'];
          AuthService.currentRoleId = user['role_id'];

          final namaUser = user['user_nama_depan'] ?? 'User';

          if (!mounted) return;

          // 🔥 PERBAIKAN DI SINI 🔥
          // HAPUS kata 'await' agar kode tidak macet menunggu dialog.
          _showSuccessDialog(namaUser);

          // Biarkan dialog tampil selama 2 detik
          await Future.delayed(const Duration(seconds: 2));

          if (!mounted) return;
          // 3. Tutup Popup Sukses secara programatis
          Navigator.of(context).pop(); 
          
          // 4. Pindah ke Dashboard
          context.go('/dashboard'); 

        } else {
          // --- ❌ KODE GAGAL ---
          String message = result['message'] ?? 'Login gagal';

          // Cek apakah Pending
          if (message.toLowerCase().contains('pending') ||
              message.toLowerCase().contains('status')) {
            _showPendingDialog(message);
          } else {
            // Tampilkan Popup Merah jika password salah / user tidak ditemukan
            _showFailureDialog("Login Gagal", message);
          }
        }
      } catch (e) {
        // Tangani error koneksi / crash
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        _showFailureDialog(
            "Terjadi Kesalahan", "Gagal terhubung ke server.\n${e.toString()}");
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