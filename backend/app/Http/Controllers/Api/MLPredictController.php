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

        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png|max:10240',
        ]);


        if (!$request->hasFile('foto')) {
            Log::error('❌ Tidak ada file "foto" yang diterima dari Flutter.');
            return response()->json(['error' => 'File foto tidak ditemukan'], 400);
        }

        $file = $request->file('foto');

        try {
            // Simpan ke storage
            $path = $file->store('uploads', 'public');
            $fullPath = storage_path("app/public/{$path}");
            $publicUrl = asset("storage/{$path}");

            Log::info("📦 [Saved] Gambar disimpan: $fullPath");

            // Kirim ke Hugging Face Space
            $fastApiUrl = "https://hfaishalh-deteksi-batik-dnn.hf.space/predict";

            $response = Http::timeout(60)->attach(
                'file',
                file_get_contents($fullPath),
                basename($fullPath)
            )->post($fastApiUrl);

            if ($response->successful()) {
                $data = $response->json();

                return response()->json([
                    'kategori_prediksi' => $data['kategori_prediksi'] ?? 'Tidak diketahui',
                    'confidence' => $data['confidence'] ?? null,
                    'probabilities' => $data['probabilities'] ?? null,
                    'image_url' => $publicUrl,
                    'path' => $path
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

        // ✅ TAMBAHKAN INI
        Log::info('📸 [File Info]', [
            'original_name' => $file->getClientOriginalName(),
            'mime' => $file->getMimeType(),
            'extension' => $file->getClientOriginalExtension(),
            'size_kb' => round($file->getSize() / 1024, 2),
        ]);
    }
}
