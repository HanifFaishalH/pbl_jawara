<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\MutasiKeluargaModel;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class MutasiKeluargaController extends Controller
{
    public function index()
    {
        $mutasi = MutasiKeluargaModel::with('keluarga')
            ->orderBy('mutasi_tanggal', 'desc')
            ->get();
        return response()->json($mutasi);
    }

    public function show($id)
    {
        $mutasi = MutasiKeluargaModel::with('keluarga')->find($id);
        if (!$mutasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($mutasi);
    }

    public function store(Request $request)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized. Hanya Admin yang boleh menambah data.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'keluarga_id' => 'required|exists:t_keluarga,keluarga_id',
            'mutasi_jenis' => 'required|in:pindah_rumah,keluar_wilayah,masuk_wilayah,pindah_rt_rw',
            'mutasi_tanggal' => 'required|date',
            'mutasi_alamat_lama' => 'nullable|string',
            'mutasi_alamat_baru' => 'nullable|string',
            'mutasi_rt_lama' => 'nullable|string',
            'mutasi_rw_lama' => 'nullable|string',
            'mutasi_rt_baru' => 'nullable|string',
            'mutasi_rw_baru' => 'nullable|string',
            'mutasi_alasan' => 'nullable|string',
            'mutasi_keterangan' => 'nullable|string',
            'mutasi_status' => 'nullable|in:pending,disetujui,ditolak',
            'dokumen' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $dokumenPath = null;
        if ($request->hasFile('dokumen')) {
            $dokumenPath = $request->file('dokumen')->store('mutasi_keluarga', 'public');
        }

        $mutasi = MutasiKeluargaModel::create([
            'keluarga_id' => $request->keluarga_id,
            'mutasi_jenis' => $request->mutasi_jenis,
            'mutasi_tanggal' => $request->mutasi_tanggal,
            'mutasi_alamat_lama' => $request->mutasi_alamat_lama,
            'mutasi_alamat_baru' => $request->mutasi_alamat_baru,
            'mutasi_rt_lama' => $request->mutasi_rt_lama,
            'mutasi_rw_lama' => $request->mutasi_rw_lama,
            'mutasi_rt_baru' => $request->mutasi_rt_baru,
            'mutasi_rw_baru' => $request->mutasi_rw_baru,
            'mutasi_alasan' => $request->mutasi_alasan,
            'mutasi_keterangan' => $request->mutasi_keterangan,
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

        $mutasi = MutasiKeluargaModel::find($id);
        if (!$mutasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'keluarga_id' => 'required|exists:t_keluarga,keluarga_id',
            'mutasi_jenis' => 'required|in:pindah_rumah,keluar_wilayah,masuk_wilayah,pindah_rt_rw',
            'mutasi_tanggal' => 'required|date',
            'mutasi_alamat_lama' => 'nullable|string',
            'mutasi_alamat_baru' => 'nullable|string',
            'mutasi_rt_lama' => 'nullable|string',
            'mutasi_rw_lama' => 'nullable|string',
            'mutasi_rt_baru' => 'nullable|string',
            'mutasi_rw_baru' => 'nullable|string',
            'mutasi_alasan' => 'nullable|string',
            'mutasi_keterangan' => 'nullable|string',
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
            $data['mutasi_dokumen'] = $request->file('dokumen')->store('mutasi_keluarga', 'public');
        }

        $mutasi->update($data);

        return response()->json(['message' => 'Update berhasil', 'data' => $mutasi]);
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $mutasi = MutasiKeluargaModel::find($id);
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

        $mutasi = MutasiKeluargaModel::find($id);
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
