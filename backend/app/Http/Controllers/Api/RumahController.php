<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\RumahModel;
use Illuminate\Support\Facades\Validator;

class RumahController extends Controller
{
    public function index()
    {
        $rumah = RumahModel::with(['keluarga', 'warga'])->orderBy('rumah_alamat', 'asc')->get();
        return response()->json($rumah);
    }

    public function show($id)
    {
        $rumah = RumahModel::with(['keluarga', 'warga'])->find($id);
        if (!$rumah) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($rumah);
    }

    public function store(Request $request)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized. Hanya Admin yang boleh menambah data.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'rumah_alamat' => 'required|string',
            'rumah_rt' => 'nullable|string',
            'rumah_rw' => 'nullable|string',
            'rumah_kelurahan' => 'nullable|string',
            'rumah_kecamatan' => 'nullable|string',
            'rumah_kota' => 'nullable|string',
            'rumah_provinsi' => 'nullable|string',
            'rumah_kode_pos' => 'nullable|string',
            'rumah_luas_tanah' => 'nullable|string',
            'rumah_luas_bangunan' => 'nullable|string',
            'rumah_status_kepemilikan' => 'nullable|in:milik_sendiri,kontrak,sewa,lainnya',
            'rumah_jumlah_penghuni' => 'nullable|integer',
            'rumah_status' => 'nullable|in:aktif,nonaktif'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $rumah = RumahModel::create($request->all());
        return response()->json(['message' => 'Data rumah berhasil dibuat', 'data' => $rumah], 201);
    }

    public function update(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $rumah = RumahModel::find($id);
        if (!$rumah) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'rumah_alamat' => 'required|string',
            'rumah_rt' => 'nullable|string',
            'rumah_rw' => 'nullable|string',
            'rumah_kelurahan' => 'nullable|string',
            'rumah_kecamatan' => 'nullable|string',
            'rumah_kota' => 'nullable|string',
            'rumah_provinsi' => 'nullable|string',
            'rumah_kode_pos' => 'nullable|string',
            'rumah_luas_tanah' => 'nullable|string',
            'rumah_luas_bangunan' => 'nullable|string',
            'rumah_status_kepemilikan' => 'nullable|in:milik_sendiri,kontrak,sewa,lainnya',
            'rumah_jumlah_penghuni' => 'nullable|integer',
            'rumah_status' => 'nullable|in:aktif,nonaktif'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $rumah->update($request->all());
        return response()->json(['message' => 'Update berhasil', 'data' => $rumah]);
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $rumah = RumahModel::find($id);
        if (!$rumah) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $rumah->delete();
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
