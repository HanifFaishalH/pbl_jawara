<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\MutasiWargaModel;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class MutasiWargaController extends Controller
{
    public function index()
    {
        $mutasi = MutasiWargaModel::with('warga')
            ->orderBy('mutasi_tanggal', 'desc')
            ->get();
        return response()->json($mutasi);
    }

    public function show($id)
    {
        $mutasi = MutasiWargaModel::with('warga')->find($id);
        if (!$mutasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($mutasi);
    }

    public function store(Request $request)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validator = Validator::make($request->all(), [
            'warga_id' => 'required|exists:t_warga,warga_id',
            'mutasi_jenis' => 'required|in:kelahiran,kematian,pindah_masuk,pindah_keluar,perubahan_status',
            'mutasi_tanggal' => 'required|date',
            'mutasi_keterangan' => 'nullable|string',
            'mutasi_alamat_asal' => 'nullable|string',
            'mutasi_alamat_tujuan' => 'nullable|string',
            'mutasi_status' => 'nullable|in:pending,disetujui,ditolak',
            'dokumen' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $dokumenPath = null;
        if ($request->hasFile('dokumen')) {
            $dokumenPath = $request->file('dokumen')->store('mutasi_warga', 'public');
        }

        $mutasi = MutasiWargaModel::create([
            'warga_id' => $request->warga_id,
            'mutasi_jenis' => $request->mutasi_jenis,
            'mutasi_tanggal' => $request->mutasi_tanggal,
            'mutasi_keterangan' => $request->mutasi_keterangan,
            'mutasi_alamat_asal' => $request->mutasi_alamat_asal,
            'mutasi_alamat_tujuan' => $request->mutasi_alamat_tujuan,
            'mutasi_status' => $request->mutasi_status ?? 'pending',
            'mutasi_dokumen' => $dokumenPath
        ]);

        return response()->json(['message' => 'Mutasi berhasil dibuat', 'data' => $mutasi], 201);
    }

    public function update(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $mutasi = MutasiWargaModel::find($id);
        if (!$mutasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'warga_id' => 'required|exists:t_warga,warga_id',
            'mutasi_jenis' => 'required|in:kelahiran,kematian,pindah_masuk,pindah_keluar,perubahan_status',
            'mutasi_tanggal' => 'required|date',
            'mutasi_keterangan' => 'nullable|string',
            'mutasi_alamat_asal' => 'nullable|string',
            'mutasi_alamat_tujuan' => 'nullable|string',
            'mutasi_status' => 'nullable|in:pending,disetujui,ditolak',
            'dokumen' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $data = $request->except(['dokumen']);

        if ($request->hasFile('dokumen')) {
            if ($mutasi->mutasi_dokumen) {
                Storage::disk('public')->delete($mutasi->mutasi_dokumen);
            }
            $data['mutasi_dokumen'] = $request->file('dokumen')->store('mutasi_warga', 'public');
        }

        $mutasi->update($data);

        return response()->json(['message' => 'Update berhasil', 'data' => $mutasi]);
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $mutasi = MutasiWargaModel::find($id);
        if (!$mutasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        if ($mutasi->mutasi_dokumen) {
            Storage::disk('public')->delete($mutasi->mutasi_dokumen);
        }

        $mutasi->delete();
        return response()->json(['message' => 'Data berhasil dihapus']);
    }

    public function updateStatus(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $mutasi = MutasiWargaModel::find($id);
        if (!$mutasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'mutasi_status' => 'required|in:pending,disetujui,ditolak'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $mutasi->update(['mutasi_status' => $request->mutasi_status]);

        return response()->json(['message' => 'Status berhasil diupdate', 'data' => $mutasi]);
    }
}
