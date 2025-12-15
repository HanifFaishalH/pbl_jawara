<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PemasukanModel;
use App\Models\PengeluaranModel;
use App\Models\usersModel;
use App\Helpers\NotifikasiHelper;

class LaporanKeuanganController extends Controller
{
    // Semua pemasukan - list + filter
    // Access: Admin (1), Ketua RW (2), Ketua RT (3), Sekretaris (4), Bendahara (5)
    public function pemasukanIndex(Request $request)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Semua role kecuali Warga (6) boleh akses
        if ($roleId == 6) {
            return response()->json([
                'success' => false,
                'message' => 'Warga tidak memiliki akses ke laporan keuangan detail'
            ], 403);
        }
        
        $q = PemasukanModel::with('kategori');

        if ($request->filled('q')) {
            $term = (string) $request->get('q');
            $q->where('judul', 'like', "%{$term}%");
        }
        if ($request->filled('from')) {
            $q->where('tanggal', '>=', $request->get('from'));
        }
        if ($request->filled('to')) {
            $q->where('tanggal', '<=', $request->get('to'));
        }

        return response()->json($q->orderByDesc('tanggal')->paginate(15));
    }

    // Semua pengeluaran - list + filter
    // Access: Admin (1), Ketua RW (2), Ketua RT (3), Sekretaris (4), Bendahara (5)
    public function pengeluaranIndex(Request $request)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Semua role kecuali Warga (6) boleh akses
        if ($roleId == 6) {
            return response()->json([
                'success' => false,
                'message' => 'Warga tidak memiliki akses ke laporan keuangan detail'
            ], 403);
        }
        
        $q = PengeluaranModel::with('kategori');

        if ($request->filled('q')) {
            $term = (string) $request->get('q');
            $q->where('judul', 'like', "%{$term}%");
        }
        if ($request->filled('from')) {
            $q->where('tanggal', '>=', $request->get('from'));
        }
        if ($request->filled('to')) {
            $q->where('tanggal', '<=', $request->get('to'));
        }

        return response()->json($q->orderByDesc('tanggal')->paginate(15));
    }

    // CRUD Pemasukan
    // Create Access: Admin (1), Bendahara (5)
    public function pemasukanStore(Request $request)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Hanya Admin dan Bendahara yang bisa create
        if (!in_array($roleId, [1, 5])) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya Admin dan Bendahara yang dapat menambah pemasukan'
            ], 403);
        }
        $data = $request->validate([
            'judul' => 'required|string|max:150',
            'deskripsi' => 'nullable|string',
            'jumlah' => 'required|integer|min:0',
            'tanggal' => 'required|date',
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id'
        ]);
        $data['user_id'] = $user->user_id;
        $row = PemasukanModel::create($data);
        
        // Kirim notifikasi ke Admin, Ketua RW, Sekretaris, Bendahara (kecuali pembuat)
        $notifRoles = [1, 2, 4, 5];
        $userIds = usersModel::whereIn('role_id', $notifRoles)
            ->where('user_id', '!=', $user->user_id)
            ->where('status', 'Diterima')
            ->pluck('user_id')
            ->toArray();
        
        if (!empty($userIds)) {
            NotifikasiHelper::createBulk(
                userIds: $userIds,
                judul: 'Pemasukan Baru',
                pesan: "{$user->user_nama_depan} menambahkan pemasukan: {$row->judul} (Rp " . number_format($row->jumlah, 0, ',', '.') . ")",
                tipe: 'success',
                link: '/laporan-keuangan'
            );
        }
        
        return response()->json(['message' => 'Pemasukan ditambahkan', 'data' => $row], 201);
    }

    // Update Access: Admin (1), Ketua RW (2), Ketua RT (3), Sekretaris (4), Bendahara (5)
    public function pemasukanUpdate(Request $request, $id)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Semua role kecuali Warga boleh update
        if ($roleId == 6) {
            return response()->json([
                'success' => false,
                'message' => 'Warga tidak memiliki akses untuk mengubah data keuangan'
            ], 403);
        }
        
        $row = PemasukanModel::where('pemasukan_id', $id)->firstOrFail();
        $data = $request->validate([
            'judul' => 'sometimes|required|string|max:150',
            'deskripsi' => 'nullable|string',
            'jumlah' => 'sometimes|required|integer|min:0',
            'tanggal' => 'sometimes|required|date',
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id'
        ]);
        $row->update($data);
        return response()->json(['message' => 'Pemasukan diperbarui', 'data' => $row]);
    }

    // Delete Access: Admin (1) only
    public function pemasukanDestroy(Request $request, $id)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Hanya Admin yang bisa delete
        if ($roleId != 1) {
            return response()->json([
                'message' => 'Hanya Admin yang dapat menghapus data keuangan'
            ], 403);
        }
        
        $row = PemasukanModel::where('pemasukan_id', $id)->firstOrFail();
        $row->delete();
        return response()->json(['message' => 'Pemasukan dihapus']);
    }

    // CRUD Pengeluaran
    // Create Access: Admin (1), Bendahara (5)
    public function pengeluaranStore(Request $request)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Hanya Admin dan Bendahara yang bisa create
        if (!in_array($roleId, [1, 5])) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya Admin dan Bendahara yang dapat menambah pengeluaran'
            ], 403);
        }
        $data = $request->validate([
            'judul' => 'required|string|max:150',
            'deskripsi' => 'nullable|string',
            'jumlah' => 'required|integer|min:0',
            'tanggal' => 'required|date',
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id'
        ]);
        $data['user_id'] = $user->user_id;
        $row = PengeluaranModel::create($data);
        
        // Kirim notifikasi ke Admin, Ketua RW, Sekretaris, Bendahara (kecuali pembuat)
        $notifRoles = [1, 2, 4, 5];
        $userIds = usersModel::whereIn('role_id', $notifRoles)
            ->where('user_id', '!=', $user->user_id)
            ->where('status', 'Diterima')
            ->pluck('user_id')
            ->toArray();
        
        if (!empty($userIds)) {
            NotifikasiHelper::createBulk(
                userIds: $userIds,
                judul: 'Pengeluaran Baru',
                pesan: "{$user->user_nama_depan} menambahkan pengeluaran: {$row->judul} (Rp " . number_format($row->jumlah, 0, ',', '.') . ")",
                tipe: 'warning',
                link: '/laporan-keuangan'
            );
        }
        
        return response()->json(['message' => 'Pengeluaran ditambahkan', 'data' => $row], 201);
    }

    // Update Access: Admin (1), Ketua RW (2), Ketua RT (3), Sekretaris (4), Bendahara (5)
    public function pengeluaranUpdate(Request $request, $id)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Semua role kecuali Warga boleh update
        if ($roleId == 6) {
            return response()->json([
                'success' => false,
                'message' => 'Warga tidak memiliki akses untuk mengubah data keuangan'
            ], 403);
        }
        
        $row = PengeluaranModel::where('pengeluaran_id', $id)->firstOrFail();
        $data = $request->validate([
            'judul' => 'sometimes|required|string|max:150',
            'deskripsi' => 'nullable|string',
            'jumlah' => 'sometimes|required|integer|min:0',
            'tanggal' => 'sometimes|required|date',
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id'
        ]);
        $row->update($data);
        return response()->json(['message' => 'Pengeluaran diperbarui', 'data' => $row]);
    }

    // Delete Access: Admin (1) only
    public function pengeluaranDestroy(Request $request, $id)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Hanya Admin yang bisa delete
        if ($roleId != 1) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya Admin yang dapat menghapus data keuangan'
            ], 403);
        }
        
        $row = PengeluaranModel::where('pengeluaran_id', $id)->firstOrFail();
        $row->delete();
        return response()->json(['message' => 'Pengeluaran dihapus']);
    }

    // Ringkasan laporan: total pemasukan/pengeluaran & saldo periode
    // Access: Admin (1), Ketua RW (2), Ketua RT (3), Sekretaris (4), Bendahara (5)
    public function ringkasan(Request $request)
    {
        $user = $request->user();
        $roleId = $user->role_id;
        
        // Semua role kecuali Warga boleh akses ringkasan
        if ($roleId == 6) {
            return response()->json([
                'success' => false,
                'message' => 'Warga tidak memiliki akses ke laporan keuangan'
            ], 403);
        }
        
        $from = $request->get('from');
        $to = $request->get('to');

        $pemasukan = PemasukanModel::query()
            ->when($from, fn($q) => $q->where('tanggal', '>=', $from))
            ->when($to, fn($q) => $q->where('tanggal', '<=', $to))
            ->sum('jumlah');

        $pengeluaran = PengeluaranModel::query()
            ->when($from, fn($q) => $q->where('tanggal', '>=', $from))
            ->when($to, fn($q) => $q->where('tanggal', '<=', $to))
            ->sum('jumlah');

        return response()->json([
            'pemasukan' => (int)$pemasukan,
            'pengeluaran' => (int)$pengeluaran,
            'saldo' => (int)$pemasukan - (int)$pengeluaran,
        ]);
    }
}
