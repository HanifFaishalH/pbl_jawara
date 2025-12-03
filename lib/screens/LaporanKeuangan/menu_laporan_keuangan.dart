import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../services/finance_service.dart';

class MenuLaporanKeuangan extends StatefulWidget {
  const MenuLaporanKeuangan({super.key});

  @override
  State<MenuLaporanKeuangan> createState() => _MenuLaporanKeuanganState();
}

class _MenuLaporanKeuanganState extends State<MenuLaporanKeuangan> {
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
      setState(() => _ringkasan = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat ringkasan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildRingkasanCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final totalPemasukan = _ringkasan?['pemasukan'] ?? 0;
    final totalPengeluaran = _ringkasan?['pengeluaran'] ?? 0;
    final saldo = _ringkasan?['saldo'] ?? 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ringkasan Keuangan',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadRingkasan,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSummaryRow(
              'Total Pemasukan',
              totalPemasukan,
              Icons.arrow_downward,
              Colors.green[300]!,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total Pengeluaran',
              totalPengeluaran,
              Icons.arrow_upward,
              Colors.red[300]!,
            ),
            const Divider(height: 24, color: Colors.white54, thickness: 1),
            _buildSummaryRow(
              'Saldo',
              saldo,
              Icons.account_balance_wallet,
              Colors.white,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, IconData icon, Color color, {bool isBold = false}) {
    final textTheme = Theme.of(context).textTheme;
    final formatted = 'Rp ${NumberFormat.decimalPattern('id').format(amount)}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              Text(
                formatted,
                style: textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      // Aktifkan agar body bisa “tembus” ke bawah navigation bar yang melayang
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, right: 16, left: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRingkasanCard(),
                  const SizedBox(height: 16),
                  const MenuLaporanKeuanganHeader(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuLaporanKeuanganItem extends StatefulWidget {
  const MenuLaporanKeuanganItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  State<MenuLaporanKeuanganItem> createState() =>
      _MenuLaporanKeuanganItemState();
}

class _MenuLaporanKeuanganItemState extends State<MenuLaporanKeuanganItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push(widget.route),
      // Gunakan onHover untuk mengubah state
      onHover: (hovering) {
        setState(() {
          _isHovering = hovering;
        });
      },
      borderRadius: BorderRadius.circular(
        16,
      ), // Samakan radius dengan container
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50), // Animasi halus
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _isHovering
              ? colorScheme
                    .surfaceVariant // Beri sedikit warna latar saat hover
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(widget.icon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center, // Agar rapi jika label 2 baris
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuLaporanKeuanganHeader extends StatelessWidget {
  const MenuLaporanKeuanganHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = [
      {
        'label': 'Semua Pemasukan',
        'icon': Icons.account_balance_wallet_outlined,
        'route': '/semua-pemasukan',
      },
      {
        'label': 'Semua Pengeluaran',
        'icon': Icons.monetization_on_outlined,
        'route': '/semua-pengeluaran',
      },
      {
        'label': 'Cetak Laporan',
        'icon': Icons.print_outlined,
        'route': '/cetak-laporan',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Menu Laporan Keuangan', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            // Tambahkan ini agar item tetap rapi di atas
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((e) {
              // Ganti blok InkWell lama dengan widget baru ini
              // Bungkus dengan Expanded agar area tap/hover merata
              return Expanded(
                child: MenuLaporanKeuanganItem(
                  icon: e['icon'] as IconData,
                  label: e['label'] as String,
                  route: e['route'] as String,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
