import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart'; // 1. IMPORT AUTH SERVICE

// ====== Screens Auth & Dashboard ======
import 'package:jawaramobile_1/screens/Auth/login_screens.dart';
import 'package:jawaramobile_1/screens/Auth/register_screens.dart';
import 'package:jawaramobile_1/screens/Dashboard/dashboard_selector.dart';

// ====== Screens Lainnya (Import tetap sama) ======
import 'package:jawaramobile_1/screens/Mutasi/mutasi_detail_page.dart';
import 'package:jawaramobile_1/screens/Mutasi/mutasi_page.dart';
import 'package:jawaramobile_1/screens/data_warga_rumah.dart';

// ====== Pemasukan ======
import 'package:jawaramobile_1/screens/Pemasukan/menu_pemasukan.dart';
import 'package:jawaramobile_1/screens/Pemasukan/kategori_iuran.dart';
import 'package:jawaramobile_1/screens/Pemasukan/detail_kategori_iuran.dart';
import 'package:jawaramobile_1/screens/Pemasukan/tagih_iuran_page.dart';
import 'package:jawaramobile_1/screens/Pemasukan/daftar_tagihan.dart';
import 'package:jawaramobile_1/screens/Pemasukan/detail_tagihan.dart';
import 'package:jawaramobile_1/screens/Pemasukan/lain_lain.dart';

// ====== Pengeluaran ======
import 'package:jawaramobile_1/screens/pengeluaran/pengeluaran_screen.dart';
import 'package:jawaramobile_1/screens/pengeluaran/tambah_pengeluaran_screen.dart';
import 'package:jawaramobile_1/screens/pengeluaran/detail_pengeluaran_screen.dart';

// ====== Laporan Keuangan ======
import 'package:jawaramobile_1/screens/LaporanKeuangan/semua_pengeluaran.dart';
import 'package:jawaramobile_1/screens/LaporanKeuangan/detail_pengeluaran.dart';
import 'package:jawaramobile_1/screens/LaporanKeuangan/semua_pemasukan.dart';
import 'package:jawaramobile_1/screens/LaporanKeuangan/detail_pemasukan.dart';
import 'package:jawaramobile_1/screens/LaporanKeuangan/cetak_laporan_screen.dart';
import 'package:jawaramobile_1/screens/LaporanKeuangan/menu_laporan_keuangan.dart';

// ====== Kegiatan ======
import 'package:jawaramobile_1/screens/Kegiatan/kegiatan_screen.dart';
import 'package:jawaramobile_1/screens/Kegiatan/tambah_kegiatan_form.dart';
import 'package:jawaramobile_1/screens/Kegiatan/detail_kegiatan_screen.dart';
// import 'package:jawaramobile_1/screens/Kegiatan/edit_kegiatan.dart'; // Tidak dipakai karena reuse form

// ====== Broadcast ======
import 'package:jawaramobile_1/screens/Broadcast/daftar_broadcast.dart';
import 'package:jawaramobile_1/screens/Broadcast/tambah_broadcast.dart';
import 'package:jawaramobile_1/screens/Broadcast/detail_broadcast.dart';
import 'package:jawaramobile_1/screens/Broadcast/edit_broadcast.dart';

// ====== LogActivity ======
import 'package:jawaramobile_1/screens/LogActivity/log_activity_screen.dart';
import 'package:jawaramobile_1/screens/LogActivity/detail_log_activity_screen.dart';

// ====== Manajemen Pengguna ======
import 'package:jawaramobile_1/screens/ManajemenPengguna/daftar_pengguna_screen.dart';
import 'package:jawaramobile_1/screens/ManajemenPengguna/tambah_pengguna_screen.dart';

// ====== Channel Transfer ======
import 'package:jawaramobile_1/screens/ChannelTransfer/daftar_channel_screen.dart';
import 'package:jawaramobile_1/screens/ChannelTransfer/tambah_channel_screen.dart';

// ====== Lainnya ======
import 'package:jawaramobile_1/screens/penerimaan_warga_screen.dart';
import 'package:jawaramobile_1/screens/dashboard_aspirasi.dart';

// ====== Marketplace ======
import 'package:jawaramobile_1/screens/Marketplace/menu_marketplace.dart';
import 'package:jawaramobile_1/screens/Marketplace/daftar_barang_jual.dart';
import 'package:jawaramobile_1/screens/Marketplace/detail_barang_jual.dart';
import 'package:jawaramobile_1/screens/Marketplace/add_barang_jual.dart';
import 'package:jawaramobile_1/screens/Marketplace/daftar_barang_beli.dart';
import 'package:jawaramobile_1/screens/Marketplace/detail_barang_beli.dart';
import 'package:jawaramobile_1/screens/Marketplace/checkout_barang.dart';
import 'package:jawaramobile_1/screens/Marketplace/pesanan_masuk.dart';
import 'package:jawaramobile_1/screens/Marketplace/detail_pesanan_masuk.dart';
import 'package:jawaramobile_1/screens/Marketplace/riwayat_pesanan_page.dart';
import 'package:jawaramobile_1/screens/Marketplace/detail_riwayat_pesanan_page.dart';
import 'package:jawaramobile_1/screens/Marketplace/keranjang_page.dart';

final appRouter = GoRouter(
  // 2. LOGIKA INITIAL LOCATION
  // Jika token ada di AuthService, langsung ke Dashboard. Jika tidak, ke Login.
  initialLocation: AuthService.token != null ? '/dashboard' : '/login',

  // 3. LOGIKA REDIRECT (PENJAGA KEAMANAN)
  // Fungsi ini dijalankan setiap kali navigasi berpindah
  redirect: (context, state) {
    // Cek status login saat ini
    final bool isLoggedIn = AuthService.token != null;
    
    // Cek apakah user sedang berada di halaman Login atau Register
    final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    // SKENARIO A: User BELUM Login, tapi mencoba buka halaman lain (misal dashboard)
    if (!isLoggedIn && !isLoggingIn) {
      return '/login'; // Tendang ke login
    }

    // SKENARIO B: User SUDAH Login, tapi mencoba buka halaman login lagi
    if (isLoggedIn && isLoggingIn) {
      return '/dashboard'; // Arahkan ke dashboard
    }

    // Jika tidak ada masalah, biarkan user lewat
    return null;
  },

  routes: <GoRoute>[
    // ====== Autentikasi ======
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreens(),
    ),

    // ====== Dashboard & Menu ======
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardSelector(),
    ),
    GoRoute(
      path: '/menu-popup',
      name: 'menu-popup',
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: const Center(),
      ),
    ),

    // ====== Data Warga ======
    GoRoute(
      path: '/data-warga-rumah',
      name: 'data-warga-rumah',
      builder: (context, state) => const DataWargaPage(),
    ),

    // ====== Pemasukan ======
    GoRoute(
      path: '/menu-pemasukan',
      name: 'menu-pemasukan',
      builder: (context, state) => const MenuPemasukan(),
    ),
    GoRoute(
      path: '/kategori-iuran',
      name: 'kategori-iuran',
      builder: (context, state) => const KategoriIuran(),
    ),
    GoRoute(
      path: '/detail-kategori',
      name: 'detail-kategori',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailKategoriIuran(kategoriData: data);
      },
    ),
    GoRoute(
      path: '/tagih-iuran',
      name: 'tagih-iuran',
      builder: (context, state) => const TagihIuranPage(),
    ),
    GoRoute(
      path: '/daftar-tagihan',
      name: 'daftar-tagihan',
      builder: (context, state) => const DaftarTagihan(),
    ),
    GoRoute(
      path: '/detail-tagihan',
      name: 'detail-tagihan',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailTagihan(kategoriData: data);
      },
    ),
    GoRoute(
      path: '/pemasukan-lain',
      name: 'pemasukan-lain',
      builder: (context, state) => const PemasukanLain(),
    ),

    // ====== Pengeluaran ======
    GoRoute(
      path: '/pengeluaran',
      name: 'pengeluaran',
      builder: (context, state) => const PengeluaranScreen(),
    ),
    GoRoute(
      path: '/tambah-pengeluaran',
      name: 'tambah-pengeluaran',
      builder: (context, state) => const TambahPengeluaranScreen(),
    ),
    GoRoute(
      path: '/detail-pengeluaran',
      name: 'detail-pengeluaran',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailPengeluaranScreen(pengeluaranData: data);
      },
    ),

    // ====== Laporan Keuangan ======
    GoRoute(
      path: '/laporan-keuangan',
      name: 'laporan-keuangan',
      builder: (context, state) => const MenuLaporanKeuangan(),
    ),
    GoRoute(
      path: '/semua-pengeluaran',
      name: 'semua-pengeluaran',
      builder: (context, state) => const Pengeluaran(),
    ),
    GoRoute(
      path: '/detail-pengeluaran-all',
      name: 'detail-pengeluaran-all',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailPengeluaran(pengeluaranData: data);
      },
    ),
    GoRoute(
      path: '/semua-pemasukan',
      name: 'semua-pemasukan',
      builder: (context, state) => const Pemasukan(),
    ),
    GoRoute(
      path: '/detail-pemasukan-all',
      name: 'detail-pemasukan-all',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailPemasukan(pemasukanData: data);
      },
    ),
    GoRoute(
      path: '/cetak-laporan',
      name: 'cetak-laporan',
      builder: (context, state) => const CetakLaporanScreen(),
    ),

    // ====== Kegiatan (Updated Route) ======
    GoRoute(
      path: '/kegiatan',
      name: 'kegiatan',
      builder: (context, state) => const KegiatanScreen(),
    ),
    GoRoute(
      path: '/tambah-kegiatan',
      name: 'tambah-kegiatan',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Tambah Kegiatan"),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: TambahKegiatanForm(),
          ),
        );
      },
    ),
    GoRoute(
      path: '/detail-kegiatan',
      name: 'detail-kegiatan',
      builder: (context, state) {
        // Ambil data dari extra
        final data = state.extra as Map<String, dynamic>; 
        
        // Ubah 'data:' menjadi 'kegiatanData:'
        return DetailKegiatanScreen(kegiatanData: data); 
      },
    ),
    GoRoute(
      path: '/edit-kegiatan',
      name: 'edit-kegiatan',
      builder: (context, state) {
        final data = state.extra; 
        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Kegiatan"),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: TambahKegiatanForm(initialData: data), 
          ),
        );
      },
    ),

    // ====== Broadcast ======
    GoRoute(
      path: '/broadcast',
      name: 'broadcast',
      builder: (context, state) => const BroadcastScreen(),
    ),
    GoRoute(
      path: '/tambah-broadcast',
      name: 'tambah-broadcast',
      builder: (context, state) => const TambahBroadcastScreen(),
    ),
    GoRoute(
      path: '/detail-broadcast',
      name: 'detail-broadcast',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailBroadcastScreen(broadcastData: data);
      },
    ),
    GoRoute(
      path: '/edit-broadcast',
      name: 'edit-broadcast',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return EditBroadcastScreen(broadcastData: data);
      },
    ),

    // ====== LogActivity ======
    GoRoute(
      path: '/log-aktivitas',
      name: 'log-aktivitas',
      builder: (context, state) => const LogActivityScreen(),
    ),
    GoRoute(
      path: '/detail-log-aktivitas',
      name: 'detail-log-aktivitas',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return DetailLogActivityScreen(logData: data);
      },
    ),

    // ====== Manajemen Pengguna ======
    GoRoute(
      path: '/manajemen-pengguna',
      name: 'manajemen-pengguna',
      builder: (context, state) => const DaftarPenggunaScreen(),
    ),
    GoRoute(
      path: '/tambah-pengguna',
      name: 'tambah-pengguna',
      builder: (context, state) => const TambahPenggunaScreen(),
    ),

    // ====== Channel Transfer ======
    GoRoute(
      path: '/daftar-channel',
      name: 'daftar-channel',
      builder: (context, state) => const DaftarChannelScreen(),
    ),
    GoRoute(
      path: '/tambah-channel',
      name: 'tambah-channel',
      builder: (context, state) => const TambahChannelScreen(),
    ),
    GoRoute(
      path: '/channel-transfer',
      name: 'channel-transfer',
      builder: (context, state) => const DaftarChannelScreen(),
    ),

    // ====== Lain-lain ======
    GoRoute(
      path: '/penerimaan-warga',
      name: 'penerimaan-warga',
      builder: (context, state) => const PenerimaanWargaScreen(),
    ),
    GoRoute(
      path: '/mutasi',
      name: 'mutasi',
      builder: (context, state) => MutasiPage(),
    ),
    GoRoute(
      path: '/mutasi-detail',
      name: 'mutasi-detail',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return MutasiDetailPage(data: data);
      },
    ),
    GoRoute(
      path: '/dashboard-aspirasi',
      name: 'dashboard-aspirasi',
      builder: (context, state) => const DashboardAspirasi(),
    ),
    
    // ====== MARKETPLACE ======
    GoRoute(
      path: '/menu-marketplace',
      name: 'menu-marketplace',
      builder: (context, state) => const MarketplaceMenu(),
    ),
    GoRoute(
      path: '/keranjang',
      name: 'keranjang',
      builder: (context, state) => const KeranjangPage(),
    ),
    GoRoute(
      path: '/daftar-barang-jual',
      builder: (context, state) => const DaftarBarang(),
    ),
    GoRoute(
      path: '/detail-barang-jual',
      builder: (context, state) {
        final item = state.extra as Map<String, String>;
        return DetailBarang(barangData: item);
      },
    ),
    GoRoute(
      path: '/add-barang',
      builder: (context, state) => const AddBarangScreen(),
    ),
    GoRoute(
      path: '/daftar-pembelian',
      builder: (context, state) => const DaftarPembelian(),
    ),
    GoRoute(
      path: '/detail-barang-beli',
      builder: (context, state) {
        final item = state.extra as Map<String, String>;
        return DetailBarangBeli(barangData: item);
      },
    ),
    GoRoute(
      path: '/checkout-barang',
      builder: (context, state) {
        final data = state.extra; 
        return CheckoutBarang(checkoutData: data);
      },
    ),
    GoRoute(
        path: '/pesanan-masuk',
        builder: (context, state) => const PesananMasuk(),
    ),
    GoRoute(
      path: '/detail-pesanan-masuk',
      builder: (context, state) {
        final item = state.extra as Map<String, String>;
        return DetailPesananMasuk(pesananData: item);
      },
    ),
    GoRoute(
      path: '/riwayat-pesanan',
      builder: (context, state) => const RiwayatPesananPage(),
    ),
    GoRoute(
      path: '/detail-riwayat-pesanan',
      builder: (context, state) {
        final pesanan = state.extra as Map<String, dynamic>; 
        return DetailRiwayatPesananPage(pesanan: pesanan);
      },
    ),
  ],
);