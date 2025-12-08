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

        // ✅ Pastikan ada file dikirim
        if (!$request->hasFile('foto')) {
            Log::error('❌ Tidak ada file "foto" yang diterima dari Flutter.');
            return response()->json(['error' => 'File foto tidak ditemukan'], 400);
        }

        $file = $request->file('foto');
        Log::info('🖼️ File diterima dari Flutter', [
            'name' => $file->getClientOriginalName(),
            'size' => $file->getSize(),
            'mime' => $file->getMimeType(),
        ]);

        try {
            // ✅ Kirim file ke FastAPI (pastikan port sesuai)
            $fastApiUrl = "http://127.0.0.1:5000/predict";

            $response = Http::timeout(30)->attach(
                'file', file_get_contents($file->getRealPath()), $file->getClientOriginalName()
            )->post($fastApiUrl);

            Log::info('📤 [Forwarded] Ke FastAPI', [
                'status' => $response->status(),
                'body' => substr($response->body(), 0, 400),
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return response()->json([
                    'kategori_prediksi' => $data['kategori_prediksi'] ?? 'Tidak diketahui',
                    'akurasi' => $data['akurasi'] ?? null
                ], 200);
            }

            Log::error('⚠️ [FastAPI Error]', ['response' => $response->body()]);
            return response()->json([
                'error' => 'Gagal dari model ML',
                'detail' => $response->body()
            ], 500);

        } catch (\Exception $e) {
            Log::error('💥 [Predict Error]', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'error' => 'Gagal memproses prediksi',
                'detail' => $e->getMessage()
            ], 500);
        }
    }
}
