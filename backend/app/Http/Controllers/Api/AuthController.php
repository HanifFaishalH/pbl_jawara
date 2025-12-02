<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\usersModel;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required'
        ]);

        $user = usersModel::where('email', $request->email)->first();

        // 1. Cek User & Password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah'
            ], 401);
        }

        // 🔥 2. TAMBAHKAN INI: Cek Status User 🔥
        // Sesuaikan 'Aktif' dengan value di database Anda untuk user yang sudah diterima
        if ($user->status !== 'Diterima') { 
            return response()->json([
                'message' => 'Akun Anda masih berstatus ' . $user->status . '. Harap tunggu verifikasi Admin.'
            ], 403); // 403 artinya Forbidden (Dilarang)
        }

        // 3. Buat Token (Hanya jika lolos pengecekan di atas)
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token'   => $token,
            'user'    => $user
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    public function register(Request $request)
{
    $validated = $request->validate([
        'role_id'            => 'required|exists:m_role,role_id',
        'email'              => 'required|email|unique:m_user,email',
        'password'           => 'required|string|min:6|confirmed',
        'user_nama_depan'    => 'required|string|max:50',
        'user_nama_belakang' => 'nullable|string|max:50',
        'user_tanggal_lahir' => 'required|date',
        'user_alamat'        => 'required|string|max:255',
        'foto'               => 'nullable|string|max:255',
    ]);

    $user = usersModel::create([
        'role_id'            => $validated['role_id'],
        'email'              => $validated['email'],
        'password'           => Hash::make($validated['password']),
        'user_nama_depan'    => $validated['user_nama_depan'],
        'user_nama_belakang' => $validated['user_nama_belakang'] ?? '',
        'user_tanggal_lahir' => $validated['user_tanggal_lahir'],
        'user_alamat'        => $validated['user_alamat'],
        'foto'               => $validated['foto'] ?? null,
    ]);

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'message' => 'Registrasi berhasil',
        'token'   => $token,
        'user'    => $user
    ], 201);
}


    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }
}
