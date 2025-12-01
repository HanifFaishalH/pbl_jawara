<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ChannelTransferModel;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ChannelTransferController extends Controller
{
    // SEMUA USER (Login) BISA LIHAT
    public function index()
    {
        $channels = ChannelTransferModel::orderBy('created_at', 'desc')->get();
        return response()->json($channels);
    }

    public function show($id)
    {
        $channel = ChannelTransferModel::find($id);
        if (!$channel) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($channel);
    }

    // HANYA ADMIN YANG BISA TAMBAH
    public function store(Request $request)
    {
        // Cek apakah user admin (role_id 1)
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized. Hanya Admin yang boleh menambah data.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'channel_nama' => 'required|string',
            'channel_tipe' => 'required|in:bank,ewallet,qris',
            'channel_nomor' => 'required|string',
            'channel_pemilik' => 'required|string',
            'channel_catatan' => 'nullable|string',
            'channel_status' => 'nullable|in:aktif,nonaktif',
            'qr' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'thumbnail' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Upload QR jika ada
        $qrPath = null;
        if ($request->hasFile('qr')) {
            $qrPath = $request->file('qr')->store('channel_transfer/qr', 'public');
        }

        // Upload Thumbnail jika ada
        $thumbnailPath = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnailPath = $request->file('thumbnail')->store('channel_transfer/thumbnail', 'public');
        }

        $channel = ChannelTransferModel::create([
            'channel_nama' => $request->channel_nama,
            'channel_tipe' => $request->channel_tipe,
            'channel_nomor' => $request->channel_nomor,
            'channel_pemilik' => $request->channel_pemilik,
            'channel_qr' => $qrPath,
            'channel_thumbnail' => $thumbnailPath,
            'channel_catatan' => $request->channel_catatan,
            'channel_status' => $request->channel_status ?? 'aktif'
        ]);

        return response()->json(['message' => 'Channel berhasil dibuat', 'data' => $channel], 201);
    }

    // HANYA ADMIN YANG BISA UPDATE
    public function update(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $channel = ChannelTransferModel::find($id);
        if (!$channel) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'channel_nama' => 'required|string',
            'channel_tipe' => 'required|in:bank,ewallet,qris',
            'channel_nomor' => 'required|string',
            'channel_pemilik' => 'required|string',
            'channel_catatan' => 'nullable|string',
            'channel_status' => 'nullable|in:aktif,nonaktif',
            'qr' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'thumbnail' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $data = $request->except(['qr', 'thumbnail']);

        // Handle QR upload
        if ($request->hasFile('qr')) {
            if ($channel->channel_qr) {
                Storage::disk('public')->delete($channel->channel_qr);
            }
            $data['channel_qr'] = $request->file('qr')->store('channel_transfer/qr', 'public');
        }

        // Handle Thumbnail upload
        if ($request->hasFile('thumbnail')) {
            if ($channel->channel_thumbnail) {
                Storage::disk('public')->delete($channel->channel_thumbnail);
            }
            $data['channel_thumbnail'] = $request->file('thumbnail')->store('channel_transfer/thumbnail', 'public');
        }

        $channel->update($data);

        return response()->json(['message' => 'Update berhasil', 'data' => $channel]);
    }

    // HANYA ADMIN YANG BISA HAPUS
    public function destroy(Request $request, $id)
    {
        if ($request->user()->role_id != 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $channel = ChannelTransferModel::find($id);
        if (!$channel) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        // Hapus file QR jika ada
        if ($channel->channel_qr) {
            Storage::disk('public')->delete($channel->channel_qr);
        }

        // Hapus file Thumbnail jika ada
        if ($channel->channel_thumbnail) {
            Storage::disk('public')->delete($channel->channel_thumbnail);
        }

        $channel->delete();
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}
