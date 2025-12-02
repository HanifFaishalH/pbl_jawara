import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/screens/Broadcast/broadcast_screen.dart';
import 'package:jawaramobile_1/screens/PesanWarga/chat_pesan_warga_screen.dart';
import 'package:jawaramobile_1/screens/PesanWarga/pesan_warga_screen.dart';
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
import 'package:jawaramobile_1/screens/Broadcast/tambah_broadcast.dart';
import 'package:jawaramobile_1/screens/Broadcast/detail_broadcast.dart';
import 'package:jawaramobile_1/screens/Broadcast/edit_broadcast.dart';

// ====== LogActivity ======
import 'package:jawaramobile_1/screens/LogActivity/log_activity_screen.dart';
import 'package:jawaramobile_1/screens/LogActivity/detail_log_activity_screen.dart';

// ====== Activity Log ======
import 'package:jawaramobile_1/screens/ActivityLog/daftar_activity_log_screen.dart';
import 'package:jawaramobile_1/screens/ActivityLog/detail_activity_log_screen.dart';

// ====== Manajemen Pengguna ======
import 'package:jawaramobile_1/screens/ManajemenPengguna/daftar_pengguna_screen.dart';
import 'package:jawaramobile_1/screens/ManajemenPengguna/tambah_pengguna_screen.dart';

// ====== Channel Transfer ======
import 'package:jawaramobile_1/screens/ChannelTransfer/daftar_channel_screen.dart';
import 'package:jawaramobile_1/screens/ChannelTransfer/tambah_channel_screen.dart';
import 'package:jawaramobile_1/screens/ChannelTransfer/detail_channel_screen.dart';

// ====== Data Warga ======
import 'package:jawaramobile_1/screens/DataWargaRumah/form_warga_screen.dart';
import 'package:jawaramobile_1/screens/DataWargaRumah/detail_warga_screen.dart';
import 'package:jawaramobile_1/screens/DataWargaRumah/form_keluarga_screen.dart';
import 'package:jawaramobile_1/screens/DataWargaRumah/detail_keluarga_screen.dart';
import 'package:jawaramobile_1/screens/DataWargaRumah/form_rumah_screen.dart';
import 'package:jawaramobile_1/screens/DataWargaRumah/detail_rumah_screen.dart';

// ====== Mutasi Warga & Keluarga ======
import 'package:jawaramobile_1/screens/Mutasi/mutasi_screen.dart';
import 'package:jawaramobile_1/screens/Mutasi/daftar_mutasi_warga_screen.dart';
import 'package:jawaramobile_1/screens/Mutasi/daftar_mutasi_keluarga_screen.dart';
import 'package:jawaramobile_1/screens/Mutasi/form_mutasi_warga_screen.dart';
import 'package:jawaramobile_1/screens/Mutasi/form_mutasi_keluarga_screen.dart';
import 'package:jawaramobile_1/screens/Mutasi/detail_mutasi_warga_screen.dart';
import 'package:jawaramobile_1/screens/Mutasi/detail_mutasi_keluarga_screen.dart';

// ====== Lainnya ======
import 'package:jawaramobile_1/screens/penerimaan_warga_screen.dart';
//import 'package:jawaramobile_1/screens/dashboard_aspirasi.dart';

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

import 'package:jawaramobile_1/screens/Aspirasi/aspirasi_screen.dart';
import 'package:jawaramobile_1/screens/Aspirasi/tambah_aspirasi_screen.dart';
import 'package:jawaramobile_1/screens/Aspirasi/detail_aspirasi_screen.dart';
import 'package:jawaramobile_1/models/aspirasi_models.dart';

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
    // Warga
    GoRoute(
      path: '/tambah-warga',
      name: 'tambah-warga',
      builder: (context, state) => const FormWargaScreen(),
    ),
    GoRoute(
      path: '/edit-warga/:id',
      name: 'edit-warga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return FormWargaScreen(wargaId: id);
      },
    ),
    GoRoute(
      path: '/detail-warga/:id',
      name: 'detail-warga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailWargaScreen(wargaId: id);
      },
    ),
    // Keluarga
    GoRoute(
      path: '/tambah-keluarga',
      name: 'tambah-keluarga',
      builder: (context, state) => const FormKeluargaScreen(),
    ),
    GoRoute(
      path: '/edit-keluarga/:id',
      name: 'edit-keluarga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return FormKeluargaScreen(keluargaId: id);
      },
    ),
    GoRoute(
      path: '/detail-keluarga/:id',
      name: 'detail-keluarga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailKeluargaScreen(keluargaId: id);
      },
    ),
    // Rumah
    GoRoute(
      path: '/tambah-rumah',
      name: 'tambah-rumah',
      builder: (context, state) => const FormRumahScreen(),
    ),
    GoRoute(
      path: '/edit-rumah/:id',
      name: 'edit-rumah',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return FormRumahScreen(rumahId: id);
      },
    ),
    GoRoute(
      path: '/detail-rumah/:id',
      name: 'detail-rumah',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailRumahScreen(rumahId: id);
      },
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
        // gunakan dynamic agar tidak crash jika data bukan Map<String, String>
        final data = state.extra as Map<String, dynamic>;
        return DetailBroadcastScreen(broadcastData: data);
      },
    ),

    GoRoute(
      path: '/edit-broadcast',
      name: 'edit-broadcast',
      builder: (context, state) {
        // gunakan dynamic juga
        final data = state.extra as Map<String, dynamic>;
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

    // ====== Activity Log (New) ======
    GoRoute(
      path: '/activity-log',
      name: 'activity-log',
      builder: (context, state) => const DaftarActivityLogScreen(),
    ),
    GoRoute(
      path: '/detail-activity-log/:id',
      name: 'detail-activity-log',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailActivityLogScreen(logId: id);
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
    GoRoute(
      path: '/pengguna',
      redirect: (context, state) => '/pengguna',
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
      path: '/edit-channel/:id',
      name: 'edit-channel',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TambahChannelScreen(channelId: id);
      },
    ),
    GoRoute(
      path: '/detail-channel/:id',
      name: 'detail-channel',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailChannelScreen(channelId: id);
      },
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
    // ====== Mutasi (Gabungan Warga & Keluarga) ======
    GoRoute(
      path: '/mutasi',
      name: 'mutasi',
      builder: (context, state) => const MutasiScreen(),
    ),
    
    // Mutasi Lama (deprecated - untuk backward compatibility)
    GoRoute(
      path: '/mutasi-detail',
      name: 'mutasi-detail',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return MutasiDetailPage(data: data);
      },
    ),

    // ====== Mutasi Warga (Baru) ======
    GoRoute(
      path: '/daftar-mutasi-warga',
      name: 'daftar-mutasi-warga',
      builder: (context, state) => const DaftarMutasiWargaScreen(),
    ),
    GoRoute(
      path: '/tambah-mutasi-warga',
      name: 'tambah-mutasi-warga',
      builder: (context, state) => const FormMutasiWargaScreen(),
    ),
    GoRoute(
      path: '/edit-mutasi-warga/:id',
      name: 'edit-mutasi-warga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return FormMutasiWargaScreen(mutasiId: id);
      },
    ),
    GoRoute(
      path: '/detail-mutasi-warga/:id',
      name: 'detail-mutasi-warga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailMutasiWargaScreen(mutasiId: id);
      },
    ),

    // ====== Mutasi Keluarga (Baru) ======
    GoRoute(
      path: '/daftar-mutasi-keluarga',
      name: 'daftar-mutasi-keluarga',
      builder: (context, state) => const DaftarMutasiKeluargaScreen(),
    ),
    GoRoute(
      path: '/tambah-mutasi-keluarga',
      name: 'tambah-mutasi-keluarga',
      builder: (context, state) => const FormMutasiKeluargaScreen(),
    ),
    GoRoute(
      path: '/edit-mutasi-keluarga/:id',
      name: 'edit-mutasi-keluarga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return FormMutasiKeluargaScreen(mutasiId: id);
      },
    ),
    GoRoute(
      path: '/detail-mutasi-keluarga/:id',
      name: 'detail-mutasi-keluarga',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailMutasiKeluargaScreen(mutasiId: id);
      },
    ),
    GoRoute(
      path: '/aspirasi-screen',
      name: 'aspirasi-screen',
      // Class ini berasal dari file aspirasi_screen.dart
      builder: (context, state) => const DashboardAspirasi(), 
      
      routes: [
        GoRoute(
          path: 'tambah',
          name: 'tambah-aspirasi',
          builder: (context, state) => const TambahAspirasiScreen(),
        ),
        GoRoute(
          path: 'detail',
          name: 'detail-aspirasi',
          builder: (context, state) {
            // Mengambil object aspirasi yang dikirim via parameter 'extra'
            final aspirasi = state.extra as AspirasiModel;
            return DetailAspirasiScreen(aspirasi: aspirasi);
          },
        ),
      ],
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
    // ====== Pesan Warga ======
    GoRoute(
      path: '/pesan-warga',
      name: 'pesan-warga',
      builder: (context, state) => const PesanWargaScreen(),
    ),

    GoRoute(
      path: '/chat-pesan-warga',
      name: 'chat-pesan-warga',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return ChatPesanWargaScreen(
          penerimaId: args['penerimaId'],
          penerimaNama: args['penerimaNama'],
        );
      },
    ),

  ],
);