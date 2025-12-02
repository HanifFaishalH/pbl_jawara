<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\MutasiWargaModel;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use App\Services\ActivityLogService;

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

        $mutasi->load('warga');
        ActivityLogService::log(
            'mutasi_warga',
            'create',
            "Menambahkan mutasi warga {$request->mutasi_jenis}: {$mutasi->warga->warga_nama}",
            $mutasi->mutasi_id,
            null,
            $mutasi->toArray(),
            $request
        );

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

        $oldData = $mutasi->toArray();
        $mutasi->update($data);

        $mutasi->load('warga');
        ActivityLogService::log(
            'mutasi_warga',
            'update',
            "Mengubah mutasi warga {$mutasi->mutasi_jenis}: {$mutasi->warga->warga_nama}",
            $mutasi->mutasi_id,
            $oldData,
            $mutasi->fresh()->toArray(),
            $request
        );

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

        $mutasi->load('warga');
        $oldData = $mutasi->toArray();
        $mutasi->delete();

        ActivityLogService::log(
            'mutasi_warga',
            'delete',
            "Menghapus mutasi warga {$oldData['mutasi_jenis']}: {$oldData['warga']['warga_nama']}",
            $id,
            $oldData,
            null,
            $request
        );

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

        $oldStatus = $mutasi->mutasi_status;
        $mutasi->update(['mutasi_status' => $request->mutasi_status]);

        $mutasi->load('warga');
        ActivityLogService::log(
            'mutasi_warga',
            'update',
            "Mengubah status mutasi warga dari {$oldStatus} menjadi {$request->mutasi_status}: {$mutasi->warga->warga_nama}",
            $mutasi->mutasi_id,
            ['mutasi_status' => $oldStatus],
            ['mutasi_status' => $request->mutasi_status],
            $request
        );

        return response()->json(['message' => 'Status berhasil diupdate', 'data' => $mutasi]);
    }
}
