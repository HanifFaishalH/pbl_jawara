<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PemasukanModel;
use App\Models\PengeluaranModel;

class LaporanKeuanganController extends Controller
{
    // Semua pemasukan - list + filter
    public function pemasukanIndex(Request $request)
    {
        $user = $request->user();
        $q = PemasukanModel::with('kategori')
            ->where('user_id', $user->user_id);

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
    public function pengeluaranIndex(Request $request)
    {
        $user = $request->user();
        $q = PengeluaranModel::with('kategori')
            ->where('user_id', $user->user_id);

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
    public function pemasukanStore(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'judul' => 'required|string|max:150',
            'deskripsi' => 'nullable|string',
            'jumlah' => 'required|integer|min:0',
            'tanggal' => 'required|date',
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id'
        ]);
        $data['user_id'] = $user->user_id;
        $row = PemasukanModel::create($data);
        return response()->json(['message' => 'Pemasukan ditambahkan', 'data' => $row], 201);
    }

    public function pemasukanUpdate(Request $request, $id)
    {
        $user = $request->user();
        $row = PemasukanModel::where('pemasukan_id', $id)->where('user_id', $user->user_id)->firstOrFail();
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

    public function pemasukanDestroy(Request $request, $id)
    {
        $user = $request->user();
        $row = PemasukanModel::where('pemasukan_id', $id)->where('user_id', $user->user_id)->firstOrFail();
        $row->delete();
        return response()->json(['message' => 'Pemasukan dihapus']);
    }

    // CRUD Pengeluaran
    public function pengeluaranStore(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'judul' => 'required|string|max:150',
            'deskripsi' => 'nullable|string',
            'jumlah' => 'required|integer|min:0',
            'tanggal' => 'required|date',
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id'
        ]);
        $data['user_id'] = $user->user_id;
        $row = PengeluaranModel::create($data);
        return response()->json(['message' => 'Pengeluaran ditambahkan', 'data' => $row], 201);
    }

    public function pengeluaranUpdate(Request $request, $id)
    {
        $user = $request->user();
        $row = PengeluaranModel::where('pengeluaran_id', $id)->where('user_id', $user->user_id)->firstOrFail();
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

    public function pengeluaranDestroy(Request $request, $id)
    {
        $user = $request->user();
        $row = PengeluaranModel::where('pengeluaran_id', $id)->where('user_id', $user->user_id)->firstOrFail();
        $row->delete();
        return response()->json(['message' => 'Pengeluaran dihapus']);
    }

    // Ringkasan laporan: total pemasukan/pengeluaran & saldo periode
    public function ringkasan(Request $request)
    {
        $user = $request->user();
        $from = $request->get('from');
        $to = $request->get('to');

        $pemasukan = PemasukanModel::where('user_id', $user->user_id)
            ->when($from, fn($q) => $q->where('tanggal', '>=', $from))
            ->when($to, fn($q) => $q->where('tanggal', '<=', $to))
            ->sum('jumlah');

        $pengeluaran = PengeluaranModel::where('user_id', $user->user_id)
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
