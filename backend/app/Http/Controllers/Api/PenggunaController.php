<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\usersModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class PenggunaController extends Controller
{
    // 1. Ambil Daftar Pengguna
    public function index()
    {
        $users = usersModel::with('role')->orderBy('created_at', 'desc')->get();

        $data = $users->map(function($user) {
            return [
                'user_id'            => $user->user_id,
                'user_nama_depan'    => $user->user_nama_depan,
                'user_nama_belakang' => $user->user_nama_belakang,
                // 'nama' digunakan untuk tampilan list di Flutter
                'nama'               => trim($user->user_nama_depan . ' ' . $user->user_nama_belakang),
                'email'              => $user->email,
                'user_tanggal_lahir' => $user->user_tanggal_lahir,
                'user_alamat'        => $user->user_alamat,
                'status'             => $user->status ?? 'Pending',
                'role_id'            => $user->role_id,
                'role_nama'          => $user->role->role_nama ?? '-'
            ];
        });

        return response()->json(['success' => true, 'data' => $data], 200);
    }

    // 2. Tambah Pengguna
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_nama_depan'    => 'required|string|max:100',
            'user_nama_belakang' => 'nullable|string|max:100',
            'email'              => 'required|email|unique:m_user,email',
            'password'           => 'required|string|min:6',
            'role_id'            => 'required|integer', 
            'status'             => 'in:Pending,Diterima,Ditolak',
            'user_tanggal_lahir' => 'required|date', 
            'user_alamat'        => 'required|string', 
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }

        try {
            $user = usersModel::create([
                'user_nama_depan'    => $request->user_nama_depan,
                'user_nama_belakang' => $request->user_nama_belakang,
                'email'              => $request->email,
                'password'           => Hash::make($request->password),
                'role_id'            => $request->role_id,
                'status'             => $request->status ?? 'Pending',
                'user_tanggal_lahir' => $request->user_tanggal_lahir,
                'user_alamat'        => $request->user_alamat,
                'foto'               => null, 
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pengguna berhasil ditambahkan',
                'data'    => $user
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 3. Update Data Pengguna (Edit Lengkap)
    public function update(Request $request, $id)
    {
        $user = usersModel::find($id);
        if (!$user) return response()->json(['success' => false, 'message' => 'User tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'user_nama_depan'    => 'required|string|max:100',
            'user_nama_belakang' => 'nullable|string|max:100',
            // Ignore unique check untuk user ini sendiri
            'email'              => 'required|email|unique:m_user,email,'.$id.',user_id',
            'role_id'            => 'required|integer',
            'status'             => 'in:Pending,Diterima,Ditolak',
            'user_tanggal_lahir' => 'required|date',
            'user_alamat'        => 'required|string',
            'password'           => 'nullable|string|min:6', // Password opsional
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }

        try {
            $user->user_nama_depan    = $request->user_nama_depan;
            $user->user_nama_belakang = $request->user_nama_belakang;
            $user->email              = $request->email;
            $user->role_id            = $request->role_id;
            $user->status             = $request->status;
            $user->user_tanggal_lahir = $request->user_tanggal_lahir;
            $user->user_alamat        = $request->user_alamat;

            if ($request->filled('password')) {
                $user->password = Hash::make($request->password);
            }

            $user->save();

            return response()->json(['success' => true, 'message' => 'Data berhasil diperbarui']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function destroy($id)
    {
        $user = usersModel::find($id);

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan'], 404);
        }

        try {
            $user->delete();
            return response()->json(['success' => true, 'message' => 'Pengguna berhasil dihapus']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal menghapus: Data sedang digunakan sistem.'], 500);
        }
    }
}