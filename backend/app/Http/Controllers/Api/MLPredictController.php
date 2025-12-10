<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class MLPredictController extends Controller
{
    public function predict(Request $request)
    {
        Log::info('📩 [Predict] Request masuk ke /predict-batik');

        if (!$request->hasFile('foto')) {
            Log::error('❌ Tidak ada file "foto" yang diterima dari Flutter.');
            return response()->json(['error' => 'File foto tidak ditemukan'], 400);
        }

        $file = $request->file('foto');

        try {
            // ✅ Simpan dulu ke storage Laravel
            $path = $file->store('uploads', 'public');
            $fullPath = storage_path("app/public/{$path}");
            $publicUrl = asset("storage/{$path}");

            Log::info("📦 [Saved] Gambar disimpan ke storage: $fullPath");

            // ✅ Kirim file yang sudah tersimpan ke FastAPI
            $fastApiUrl = "http://127.0.0.1:5000/predict";
            $response = Http::timeout(30)->attach(
                'file', file_get_contents($fullPath), basename($fullPath)
            )->post($fastApiUrl);

            if ($response->successful()) {
                $data = $response->json();
                return response()->json([
                    'kategori_prediksi' => $data['kategori_prediksi'] ?? 'Tidak diketahui',
                    'akurasi' => $data['akurasi'] ?? null,
                    'image_url' => $publicUrl,
                    'path' => $path // 🔥 path-nya juga dikirim balik ke Flutter
                ], 200);
            }

            return response()->json([
                'error' => 'Gagal dari model ML',
                'detail' => $response->body()
            ], 500);

        } catch (\Exception $e) {
            Log::error('💥 [Predict Error]', ['message' => $e->getMessage()]);
            return response()->json([
                'error' => 'Gagal memproses prediksi',
                'detail' => $e->getMessage()
            ], 500);
        }
    }

}