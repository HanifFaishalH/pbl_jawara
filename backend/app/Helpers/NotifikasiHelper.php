<?php

namespace App\Helpers;

use App\Models\Notifikasi;

class NotifikasiHelper
{
    /**
     * Buat notifikasi baru
     * 
     * @param int $userId ID user yang akan menerima notifikasi
     * @param string $judul Judul notifikasi
     * @param string $pesan Isi pesan notifikasi
     * @param string $tipe Tipe notifikasi: info, success, warning, error
     * @param string|null $link Link tujuan (optional)
     * @return Notifikasi
     */
    public static function create(
        int $userId,
        string $judul,
        string $pesan,
        string $tipe = 'info',
        ?string $link = null
    ): Notifikasi {
        return Notifikasi::create([
            'user_id' => $userId,
            'notifikasi_judul' => $judul,
            'notifikasi_pesan' => $pesan,
            'notifikasi_tipe' => $tipe,
            'notifikasi_link' => $link,
            'is_read' => false,
        ]);
    }

    /**
     * Buat notifikasi untuk banyak user sekaligus
     * 
     * @param array $userIds Array of user IDs
     * @param string $judul Judul notifikasi
     * @param string $pesan Isi pesan notifikasi
     * @param string $tipe Tipe notifikasi
     * @param string|null $link Link tujuan
     */
    public static function createBulk(
        array $userIds,
        string $judul,
        string $pesan,
        string $tipe = 'info',
        ?string $link = null
    ): void {
        $data = [];
        $now = now();

        foreach ($userIds as $userId) {
            $data[] = [
                'user_id' => $userId,
                'notifikasi_judul' => $judul,
                'notifikasi_pesan' => $pesan,
                'notifikasi_tipe' => $tipe,
                'notifikasi_link' => $link,
                'is_read' => false,
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }

        Notifikasi::insert($data);
    }

    /**
     * Contoh penggunaan untuk event kegiatan baru
     */
    public static function kegiatanBaru(int $userId, string $namaKegiatan): void
    {
        self::create(
            userId: $userId,
            judul: 'Kegiatan Baru',
            pesan: "Kegiatan \"$namaKegiatan\" telah ditambahkan. Jangan lupa untuk hadir!",
            tipe: 'info',
            link: '/kegiatan'
        );
    }

    /**
     * Contoh untuk transaksi berhasil
     */
    public static function transaksiBarangBerhasil(int $userId, int $jumlahBarang): void
    {
        self::create(
            userId: $userId,
            judul: 'Transaksi Berhasil',
            pesan: "Pembelian $jumlahBarang barang Anda telah berhasil diproses.",
            tipe: 'success',
            link: '/riwayat-pesanan'
        );
    }

    /**
     * Contoh untuk pembayaran iuran
     */
    public static function pembayaranIuran(int $userId, string $nominal): void
    {
        self::create(
            userId: $userId,
            judul: 'Pembayaran Berhasil',
            pesan: "Pembayaran iuran sebesar $nominal telah diterima. Terima kasih!",
            tipe: 'success',
            link: '/laporan-keuangan'
        );
    }

    /**
     * Contoh untuk peringatan iuran
     */
    public static function peringatanIuran(int $userId, string $namaIuran, int $hariTersisa): void
    {
        self::create(
            userId: $userId,
            judul: 'Peringatan Iuran',
            pesan: "Iuran $namaIuran akan jatuh tempo dalam $hariTersisa hari. Segera lakukan pembayaran.",
            tipe: 'warning',
            link: '/daftar-tagihan'
        );
    }

    /**
     * Contoh untuk aspirasi
     */
    public static function aspirasiDiproses(int $userId, string $status): void
    {
        $tipe = $status === 'Disetujui' ? 'success' : 'info';
        self::create(
            userId: $userId,
            judul: 'Status Aspirasi',
            pesan: "Aspirasi Anda telah $status dan akan segera ditindaklanjuti.",
            tipe: $tipe,
            link: '/aspirasi-screen'
        );
    }

    /**
     * Kirim notifikasi ke semua admin
     * 
     * @param string $judul Judul notifikasi
     * @param string $pesan Isi pesan
     * @param string $tipe Tipe notifikasi
     * @param string|null $link Link tujuan
     */
    public static function notifyAllAdmins(
        string $judul,
        string $pesan,
        string $tipe = 'info',
        ?string $link = null
    ): void {
        $adminIds = \App\Models\usersModel::where('role_id', 1)
            ->where('status', 'Diterima')
            ->pluck('user_id')
            ->toArray();
        
        if (!empty($adminIds)) {
            self::createBulk($adminIds, $judul, $pesan, $tipe, $link);
        }
    }

    /**
     * Kirim notifikasi ke role tertentu
     * 
     * @param int $roleId ID role yang akan menerima notifikasi
     * @param string $judul Judul notifikasi
     * @param string $pesan Isi pesan
     * @param string $tipe Tipe notifikasi
     * @param string|null $link Link tujuan
     */
    public static function notifyByRole(
        int $roleId,
        string $judul,
        string $pesan,
        string $tipe = 'info',
        ?string $link = null
    ): void {
        $userIds = \App\Models\usersModel::where('role_id', $roleId)
            ->where('status', 'Diterima')
            ->pluck('user_id')
            ->toArray();
        
        if (!empty($userIds)) {
            self::createBulk($userIds, $judul, $pesan, $tipe, $link);
        }
    }

    /**
     * Kirim notifikasi ke multiple roles
     * 
     * @param array $roleIds Array of role IDs
     * @param string $judul Judul notifikasi
     * @param string $pesan Isi pesan
     * @param string $tipe Tipe notifikasi
     * @param string|null $link Link tujuan
     */
    public static function notifyMultipleRoles(
        array $roleIds,
        string $judul,
        string $pesan,
        string $tipe = 'info',
        ?string $link = null
    ): void {
        $userIds = \App\Models\usersModel::whereIn('role_id', $roleIds)
            ->where('status', 'Diterima')
            ->pluck('user_id')
            ->toArray();
        
        if (!empty($userIds)) {
            self::createBulk($userIds, $judul, $pesan, $tipe, $link);
        }
    }

    /**
     * Kirim notifikasi ke semua user kecuali role tertentu
     * 
     * @param int $excludeRoleId Role ID yang dikecualikan
     * @param string $judul Judul notifikasi
     * @param string $pesan Isi pesan
     * @param string $tipe Tipe notifikasi
     * @param string|null $link Link tujuan
     */
    public static function notifyAllExceptRole(
        int $excludeRoleId,
        string $judul,
        string $pesan,
        string $tipe = 'info',
        ?string $link = null
    ): void {
        $userIds = \App\Models\usersModel::where('role_id', '!=', $excludeRoleId)
            ->where('status', 'Diterima')
            ->pluck('user_id')
            ->toArray();
        
        if (!empty($userIds)) {
            self::createBulk($userIds, $judul, $pesan, $tipe, $link);
        }
    }
}
