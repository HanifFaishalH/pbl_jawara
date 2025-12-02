<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\KeluargaModel;
use Illuminate\Support\Facades\Validator;
use App\Services\ActivityLogService;

class KeluargaController extends Controller
{
    public function index()
    {
        $keluarga = KeluargaModel::with(['rumah', 'warga'])->orderBy('keluarga_nama_kepala', 'asc')->get();
        return response()->json($keluarga);
    }

    public function show($id)
    {
        $keluarga = KeluargaModel::with(['rumah', 'warga'])->find($id);
        if (!$keluarga) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($keluarga);
    }

    public function store(Request $request)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized. Hanya Admin yang boleh menambah data.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'keluarga_no_kk' => 'required|string|unique:t_keluarga,keluarga_no_kk',
            'keluarga_nama_kepala' => 'required|string',
            'keluarga_alamat' => 'required|string',
            'rumah_id' => 'nullable|exists:t_rumah,rumah_id',
            'keluarga_status' => 'nullable|in:aktif,nonaktif'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $keluarga = KeluargaModel::create($request->all());

        ActivityLogService::log(
            'keluarga',
            'create',
            "Menambahkan data keluarga: {$keluarga->keluarga_nama_kepala} (KK: {$keluarga->keluarga_no_kk})",
            $keluarga->keluarga_id,
            null,
            $keluarga->toArray(),
            $request
        );

        return response()->json(['message' => 'Data keluarga berhasil dibuat', 'data' => $keluarga], 201);
    }

    public function update(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $keluarga = KeluargaModel::find($id);
        if (!$keluarga) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'keluarga_no_kk' => 'required|string|unique:t_keluarga,keluarga_no_kk,' . $id . ',keluarga_id',
            'keluarga_nama_kepala' => 'required|string',
            'keluarga_alamat' => 'required|string',
            'rumah_id' => 'nullable|exists:t_rumah,rumah_id',
            'keluarga_status' => 'nullable|in:aktif,nonaktif'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $oldData = $keluarga->toArray();
        $keluarga->update($request->all());

        ActivityLogService::log(
            'keluarga',
            'update',
            "Mengubah data keluarga: {$keluarga->keluarga_nama_kepala} (KK: {$keluarga->keluarga_no_kk})",
            $keluarga->keluarga_id,
            $oldData,
            $keluarga->fresh()->toArray(),
            $request
        );

        return response()->json(['message' => 'Update berhasil', 'data' => $keluarga]);
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $keluarga = KeluargaModel::find($id);
        if (!$keluarga) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $oldData = $keluarga->toArray();
        $keluarga->delete();

        ActivityLogService::log(
            'keluarga',
            'delete',
            "Menghapus data keluarga: {$oldData['keluarga_nama_kepala']} (KK: {$oldData['keluarga_no_kk']})",
            $id,
            $oldData,
            null,
            $request
        );

        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
