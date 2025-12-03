import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/finance_service.dart';

class DashboardBendaharaScreen extends StatefulWidget {
  const DashboardBendaharaScreen({super.key});

  @override
  State<DashboardBendaharaScreen> createState() => _DashboardBendaharaScreenState();
}

class _DashboardBendaharaScreenState extends State<DashboardBendaharaScreen> {
  Map<String, dynamic>? _ringkasan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRingkasan();
  }

  Future<void> _loadRingkasan() async {
    setState(() => _loading = true);
    try {
      final data = await FinanceService.ringkasan();
      if (mounted) {
        setState(() => _ringkasan = data);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget _buildFinanceCard(
      BuildContext context, {
      required IconData icon,
      required String title,
      required String amount,
      required Color color,
      required Color iconColor,
      required Color textColor,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                amount,
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardHeader(
                      title: "Dashboard Bendahara",
                      subtitle: "Kelola keuangan dan kas warga",
                    ),
                    const SizedBox(height: 24),

                    // 💰 Ringkasan Kas
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Ringkasan Keuangan RW",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (!_loading)
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 20),
                                  onPressed: _loadRingkasan,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          if (_loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 💵 Saldo
                                  _buildFinanceCard(
                                    context,
                                    icon: Icons.account_balance_wallet_rounded,
                                    title: "Saldo",
                                    amount: "Rp ${NumberFormat.decimalPattern('id').format(_ringkasan?['saldo'] ?? 0)}",
                                    color: colors.primaryContainer.withOpacity(0.95),
                                    iconColor: colors.onPrimaryContainer,
                                    textColor: colors.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 12),

                                  // 📥 Pemasukan
                                  _buildFinanceCard(
                                    context,
                                    icon: Icons.arrow_downward_rounded,
                                    title: "Pemasukan",
                                    amount: "Rp ${NumberFormat.decimalPattern('id').format(_ringkasan?['pemasukan'] ?? 0)}",
                                    color: Colors.green.withOpacity(0.1),
                                    iconColor: Colors.green,
                                    textColor: Colors.green,
                                  ),
                                  const SizedBox(width: 12),

                                  // 📤 Pengeluaran
                                  _buildFinanceCard(
                                    context,
                                    icon: Icons.arrow_upward_rounded,
                                    title: "Pengeluaran",
                                    amount: "Rp ${NumberFormat.decimalPattern('id').format(_ringkasan?['pengeluaran'] ?? 0)}",
                                    color: Colors.red.withOpacity(0.1),
                                    iconColor: Colors.redAccent,
                                    textColor: Colors.redAccent,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                    ).animate().fadeIn(duration: 700.ms),

                    const SizedBox(height: 24),

                    // 📊 Tombol laporan keuangan
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/laporan-keuangan');
                      },
                      icon: const Icon(Icons.insert_chart_outlined),
                      label: const Text("Lihat Laporan Keuangan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // 🔹 Navbar Mengambang
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      child: BottomNavbar(),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
