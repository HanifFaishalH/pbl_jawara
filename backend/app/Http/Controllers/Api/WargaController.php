<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\WargaModel;
use App\Models\User;
use Illuminate\Support\Facades\Validator;
use App\Services\ActivityLogService;
use App\Helpers\NotifikasiHelper;

class WargaController extends Controller
{
    public function index()
    {
        $warga = WargaModel::with(['keluarga', 'rumah'])->orderBy('warga_nama', 'asc')->get();
        return response()->json($warga);
    }

    public function show($id)
    {
        $warga = WargaModel::with(['keluarga', 'rumah'])->find($id);
        if (!$warga) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($warga);
    }

    public function store(Request $request)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized. Hanya Admin yang boleh menambah data.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'warga_nama' => 'required|string',
            'warga_nik' => 'required|string|size:16|unique:t_warga,warga_nik',
            'warga_tempat_lahir' => 'nullable|string',
            'warga_tanggal_lahir' => 'nullable|date',
            'warga_jenis_kelamin' => 'nullable|in:L,P',
            'warga_agama' => 'nullable|string',
            'warga_pendidikan' => 'nullable|string',
            'warga_pekerjaan' => 'nullable|string',
            'warga_status_perkawinan' => 'nullable|string',
            'warga_telepon' => 'nullable|string',
            'warga_email' => 'nullable|email',
            'keluarga_id' => 'nullable|exists:t_keluarga,keluarga_id',
            'rumah_id' => 'nullable|exists:t_rumah,rumah_id',
            'warga_status' => 'nullable|in:aktif,nonaktif,pindah,meninggal'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $warga = WargaModel::create($request->all());
        
        ActivityLogService::log(
            'warga',
            'create',
            "Menambahkan data warga: {$warga->warga_nama} (NIK: {$warga->warga_nik})",
            $warga->warga_id,
            null,
            $warga->toArray(),
            $request
        );
        
        // Kirim notifikasi ke admin lain
        $adminIds = User::where('role_id', 1)
            ->where('user_id', '!=', $request->user()->user_id)
            ->pluck('user_id')
            ->toArray();
        if (!empty($adminIds)) {
            NotifikasiHelper::createBulk(
                userIds: $adminIds,
                judul: 'Data Warga Baru',
                pesan: "Data warga baru ditambahkan: {$warga->warga_nama} (NIK: {$warga->warga_nik})",
                tipe: 'info',
                link: '/data-warga-rumah'
            );
        }
        
        return response()->json(['message' => 'Data warga berhasil dibuat', 'data' => $warga], 201);
    }

    public function update(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $warga = WargaModel::find($id);
        if (!$warga) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'warga_nama' => 'required|string',
            'warga_nik' => 'required|string|size:16|unique:t_warga,warga_nik,' . $id . ',warga_id',
            'warga_tempat_lahir' => 'nullable|string',
            'warga_tanggal_lahir' => 'nullable|date',
            'warga_jenis_kelamin' => 'nullable|in:L,P',
            'warga_agama' => 'nullable|string',
            'warga_pendidikan' => 'nullable|string',
            'warga_pekerjaan' => 'nullable|string',
            'warga_status_perkawinan' => 'nullable|string',
            'warga_telepon' => 'nullable|string',
            'warga_email' => 'nullable|email',
            'keluarga_id' => 'nullable|exists:t_keluarga,keluarga_id',
            'rumah_id' => 'nullable|exists:t_rumah,rumah_id',
            'warga_status' => 'nullable|in:aktif,nonaktif,pindah,meninggal'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $oldData = $warga->toArray();
        $warga->update($request->all());
        
        ActivityLogService::log(
            'warga',
            'update',
            "Mengubah data warga: {$warga->warga_nama} (NIK: {$warga->warga_nik})",
            $warga->warga_id,
            $oldData,
            $warga->fresh()->toArray(),
            $request
        );
        
        return response()->json(['message' => 'Update berhasil', 'data' => $warga]);
    }

    public function destroy(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $warga = WargaModel::find($id);
        if (!$warga) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $oldData = $warga->toArray();
        $warga->delete();
        
        ActivityLogService::log(
            'warga',
            'delete',
            "Menghapus data warga: {$oldData['warga_nama']} (NIK: {$oldData['warga_nik']})",
            $id,
            $oldData,
            null,
            $request
        );
        
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
