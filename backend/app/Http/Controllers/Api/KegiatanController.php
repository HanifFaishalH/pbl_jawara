<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\KegiatanModel;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class KegiatanController extends Controller
{
    // SEMUA USER (Login) BISA LIHAT
    public function index()
    {
        $kegiatan = KegiatanModel::orderBy('kegiatan_tanggal', 'desc')->get();
        return response()->json($kegiatan);
    }

    public function show($id)
    {
        $kegiatan = KegiatanModel::find($id);
        if (!$kegiatan) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($kegiatan);
    }

    // HANYA ADMIN YANG BISA TAMBAH
    public function store(Request $request)
    {
        // Cek apakah user admin (role_id 1)
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized. Hanya Admin yang boleh menambah data.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'kegiatan_nama' => 'required|string',
            'kegiatan_kategori' => 'required|string',
            'kegiatan_pj' => 'required|string',
            'kegiatan_tanggal' => 'required|date',
            'kegiatan_lokasi' => 'required|string',
            'kegiatan_deskripsi' => 'required|string',
            'foto' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Upload Foto jika ada
        $path = null;
        if ($request->hasFile('foto')) {
            $path = $request->file('foto')->store('kegiatan', 'public');
        }

        $kegiatan = KegiatanModel::create([
            'kegiatan_nama' => $request->kegiatan_nama,
            'kegiatan_kategori' => $request->kegiatan_kategori,
            'kegiatan_pj' => $request->kegiatan_pj,
            'kegiatan_tanggal' => $request->kegiatan_tanggal,
            'kegiatan_lokasi' => $request->kegiatan_lokasi,
            'kegiatan_deskripsi' => $request->kegiatan_deskripsi,
            'kegiatan_foto' => $path
        ]);

        return response()->json(['message' => 'Kegiatan berhasil dibuat', 'data' => $kegiatan], 201);
    }

    // HANYA ADMIN YANG BISA UPDATE
    public function update(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $kegiatan = KegiatanModel::find($id);
        if (!$kegiatan) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        // Logic update sederhana (validasi bisa ditambahkan seperti store)
        $data = $request->except(['foto']); // Foto butuh handling khusus

        if ($request->hasFile('foto')) {
            // Hapus foto lama jika ada
            if ($kegiatan->kegiatan_foto) {
                Storage::disk('public')->delete($kegiatan->kegiatan_foto);
            }
            $data['kegiatan_foto'] = $request->file('foto')->store('kegiatan', 'public');
        }

        $kegiatan->update($data);

        return response()->json(['message' => 'Update berhasil', 'data' => $kegiatan]);
    }

    // HANYA ADMIN YANG BISA HAPUS
    public function destroy(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $kegiatan = KegiatanModel::find($id);
        if (!$kegiatan) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        if ($kegiatan->kegiatan_foto) {
            Storage::disk('public')->delete($kegiatan->kegiatan_foto);
        }

        $kegiatan->delete();
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}