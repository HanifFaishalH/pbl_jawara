<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TagihanModel;
use App\Models\PembayaranIuranModel;
use App\Models\WargaModel;
use App\Models\KeluargaModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class IuranController extends Controller
{
    // 1. Tarik Iuran - Buat tagihan massal ke warga
    public function tarikIuran(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'kategori_id' => 'required|exists:m_kategori,kategori_id',
            'nominal' => 'required|integer|min:1000',
            'jatuh_tempo' => 'required|date|after:today',
            'target_type' => 'required|in:all,rt,keluarga,warga', // all warga, per RT, per keluarga, per warga
            'target_ids' => 'array', // ID RT/keluarga/warga (array)
            'keterangan' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }

        try {
            DB::beginTransaction();

            $targetType = $request->target_type;
            $targetIds = $request->target_ids ?? [];
            
            // Ambil daftar warga berdasarkan target
            $wargas = [];
            
            if ($targetType === 'all') {
                // Semua warga aktif
                $wargas = WargaModel::where('warga_status', 'aktif')
                    ->with('keluarga')
                    ->get();
            } elseif ($targetType === 'rt') {
                // Warga di RT tertentu (via rumah)
                $wargas = WargaModel::whereHas('rumah', function($q) use ($targetIds) {
                    $q->whereIn('rumah_rt', $targetIds);
                })->where('warga_status', 'aktif')
                  ->with('keluarga')
                  ->get();
            } elseif ($targetType === 'keluarga') {
                // Warga di keluarga tertentu
                $wargas = WargaModel::whereIn('keluarga_id', $targetIds)
                    ->where('warga_status', 'aktif')
                    ->with('keluarga')
                    ->get();
            } elseif ($targetType === 'warga') {
                // Warga spesifik
                $wargas = WargaModel::whereIn('warga_id', $targetIds)
                    ->where('warga_status', 'aktif')
                    ->with('keluarga')
                    ->get();
            }

            if ($wargas->isEmpty()) {
                return response()->json(['success' => false, 'message' => 'Tidak ada warga yang valid untuk ditagih'], 404);
            }

            // Buat tagihan untuk setiap warga
            $tagihanCount = 0;
            $errors = [];
            
            foreach ($wargas as $warga) {
                try {
                    // Generate kode tagihan unik
                    $kodeTagihan = $this->generateKodeTagihan();
                    
                    TagihanModel::create([
                        'kategori_id' => $request->kategori_id,
                        'warga_id' => $warga->warga_id,
                        'keluarga_id' => $warga->keluarga_id,
                        'created_by' => $request->user()->user_id,
                        'kode_tagihan' => $kodeTagihan,
                        'nominal' => $request->nominal,
                        'tanggal_tagihan' => now()->toDateString(),
                        'jatuh_tempo' => $request->jatuh_tempo,
                        'status' => 'Belum Bayar',
                        'keterangan' => $request->keterangan,
                    ]);
                    
                    $tagihanCount++;
                } catch (\Exception $e) {
                    $errors[] = "Gagal buat tagihan untuk {$warga->warga_nama}: {$e->getMessage()}";
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => "Berhasil membuat {$tagihanCount} tagihan",
                'data' => [
                    'total_tagihan' => $tagihanCount,
                    'errors' => $errors,
                ],
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 2. List Tagihan (untuk admin/bendahara)
    public function listTagihan(Request $request)
    {
        try {
            $query = TagihanModel::with(['warga', 'kategori', 'keluarga', 'creator', 'pembayaran']);

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            // Filter by kategori
            if ($request->has('kategori_id')) {
                $query->where('kategori_id', $request->kategori_id);
            }

            // Filter by date range
            if ($request->has('dari_tanggal')) {
                $query->where('tanggal_tagihan', '>=', $request->dari_tanggal);
            }
            if ($request->has('sampai_tanggal')) {
                $query->where('tanggal_tagihan', '<=', $request->sampai_tanggal);
            }

            // Search by warga name or kode
            if ($request->has('q')) {
                $q = $request->q;
                $query->where(function($query) use ($q) {
                    $query->where('kode_tagihan', 'like', "%{$q}%")
                          ->orWhereHas('warga', function($query) use ($q) {
                              $query->where('warga_nama', 'like', "%{$q}%");
                          });
                });
            }

            $tagihan = $query->orderBy('tanggal_tagihan', 'desc')->get();

            $data = $tagihan->map(function($item) {
                return [
                    'tagihan_id' => $item->tagihan_id,
                    'kode_tagihan' => $item->kode_tagihan,
                    'warga_nama' => $item->warga->warga_nama ?? '-',
                    'warga_nik' => $item->warga->warga_nik ?? '-',
                    'keluarga_nama' => $item->keluarga->keluarga_no_kk ?? '-',
                    'kategori_nama' => $item->kategori->kategori_nama ?? '-',
                    'nominal' => $item->nominal,
                    'tanggal_tagihan' => $item->tanggal_tagihan->format('Y-m-d'),
                    'jatuh_tempo' => $item->jatuh_tempo->format('Y-m-d'),
                    'status' => $item->status,
                    'keterangan' => $item->keterangan,
                    'created_by' => $item->creator->user_nama_depan ?? '-',
                    'has_pembayaran' => $item->pembayaran->isNotEmpty(),
                    'pembayaran_latest' => $item->pembayaran->last(),
                ];
            });

            return response()->json(['success' => true, 'data' => $data], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 3. List Tagihan Warga (untuk warga login)
    public function tagihanSaya(Request $request)
    {
        try {
            $user = $request->user();
            
            // Cari warga berdasarkan NIK di user
            $warga = WargaModel::where('warga_nik', $user->user_nik ?? '')
                ->orWhere('warga_email', $user->email)
                ->first();

            if (!$warga) {
                return response()->json(['success' => false, 'message' => 'Data warga tidak ditemukan'], 404);
            }

            $query = TagihanModel::where('warga_id', $warga->warga_id)
                ->with(['kategori', 'pembayaran']);

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            $tagihan = $query->orderBy('tanggal_tagihan', 'desc')->get();

            $data = $tagihan->map(function($item) {
                $latestPembayaran = $item->pembayaran->last();
                
                return [
                    'tagihan_id' => $item->tagihan_id,
                    'kode_tagihan' => $item->kode_tagihan,
                    'kategori_nama' => $item->kategori->kategori_nama ?? '-',
                    'nominal' => $item->nominal,
                    'tanggal_tagihan' => $item->tanggal_tagihan->format('Y-m-d'),
                    'jatuh_tempo' => $item->jatuh_tempo->format('Y-m-d'),
                    'status' => $item->status,
                    'keterangan' => $item->keterangan,
                    'is_overdue' => now() > $item->jatuh_tempo && $item->status === 'Belum Bayar',
                    'pembayaran' => $latestPembayaran ? [
                        'pembayaran_id' => $latestPembayaran->pembayaran_id,
                        'bukti_transfer' => $latestPembayaran->bukti_transfer,
                        'jumlah_dibayar' => $latestPembayaran->jumlah_dibayar,
                        'tanggal_bayar' => $latestPembayaran->tanggal_bayar->format('Y-m-d'),
                        'status_verifikasi' => $latestPembayaran->status_verifikasi,
                        'catatan_verifikasi' => $latestPembayaran->catatan_verifikasi,
                    ] : null,
                ];
            });

            return response()->json(['success' => true, 'data' => $data], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 4. Upload Bukti Pembayaran (untuk warga)
    public function bayarTagihan(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'bukti_transfer' => 'required|image|mimes:jpeg,png,jpg|max:2048',
            'jumlah_dibayar' => 'required|integer|min:1000',
            'tanggal_bayar' => 'required|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }

        try {
            $tagihan = TagihanModel::find($id);
            
            if (!$tagihan) {
                return response()->json(['success' => false, 'message' => 'Tagihan tidak ditemukan'], 404);
            }

            if ($tagihan->status !== 'Belum Bayar') {
                return response()->json(['success' => false, 'message' => 'Tagihan sudah diproses'], 400);
            }

            // Upload bukti transfer
            $buktiPath = null;
            if ($request->hasFile('bukti_transfer')) {
                $file = $request->file('bukti_transfer');
                $filename = 'bukti_' . time() . '_' . $file->getClientOriginalName();
                $file->move(public_path('uploads/bukti_iuran'), $filename);
                $buktiPath = 'uploads/bukti_iuran/' . $filename;
            }

            // Buat record pembayaran
            $pembayaran = PembayaranIuranModel::create([
                'tagihan_id' => $id,
                'bukti_transfer' => $buktiPath,
                'jumlah_dibayar' => $request->jumlah_dibayar,
                'tanggal_bayar' => $request->tanggal_bayar,
                'status_verifikasi' => 'Pending',
            ]);

            // Update status tagihan
            $tagihan->update(['status' => 'Menunggu Verifikasi']);

            return response()->json([
                'success' => true,
                'message' => 'Bukti pembayaran berhasil diupload',
                'data' => $pembayaran,
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 5. List Pembayaran yang Perlu Diverifikasi (untuk bendahara)
    public function listPembayaranPending(Request $request)
    {
        try {
            $pembayaran = PembayaranIuranModel::with(['tagihan.warga', 'tagihan.kategori'])
                ->where('status_verifikasi', 'Pending')
                ->orderBy('created_at', 'desc')
                ->get();

            $data = $pembayaran->map(function($item) {
                return [
                    'pembayaran_id' => $item->pembayaran_id,
                    'tagihan_id' => $item->tagihan_id,
                    'kode_tagihan' => $item->tagihan->kode_tagihan ?? '-',
                    'warga_nama' => $item->tagihan->warga->warga_nama ?? '-',
                    'kategori_nama' => $item->tagihan->kategori->kategori_nama ?? '-',
                    'nominal_tagihan' => $item->tagihan->nominal ?? 0,
                    'jumlah_dibayar' => $item->jumlah_dibayar,
                    'tanggal_bayar' => $item->tanggal_bayar->format('Y-m-d'),
                    'bukti_transfer' => $item->bukti_transfer ? url($item->bukti_transfer) : null,
                    'status_verifikasi' => $item->status_verifikasi,
                    'created_at' => $item->created_at->format('Y-m-d H:i:s'),
                ];
            });

            return response()->json(['success' => true, 'data' => $data], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 6. Verifikasi Pembayaran (approve/reject)
    public function verifikasiPembayaran(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status_verifikasi' => 'required|in:Diterima,Ditolak',
            'catatan_verifikasi' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }

        try {
            $pembayaran = PembayaranIuranModel::with('tagihan')->find($id);
            
            if (!$pembayaran) {
                return response()->json(['success' => false, 'message' => 'Pembayaran tidak ditemukan'], 404);
            }

            $pembayaran->update([
                'status_verifikasi' => $request->status_verifikasi,
                'verified_by' => $request->user()->user_id,
                'verified_at' => now(),
                'catatan_verifikasi' => $request->catatan_verifikasi,
            ]);

            // Update status tagihan
            $statusTagihan = $request->status_verifikasi === 'Diterima' ? 'Lunas' : 'Ditolak';
            $pembayaran->tagihan->update(['status' => $statusTagihan]);

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran berhasil diverifikasi',
                'data' => $pembayaran,
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // Helper: Generate kode tagihan unik
    private function generateKodeTagihan()
    {
        $prefix = 'IR-' . date('Y') . '-';
        $lastTagihan = TagihanModel::where('kode_tagihan', 'like', $prefix . '%')
            ->orderBy('tagihan_id', 'desc')
            ->first();

        if ($lastTagihan) {
            $lastNumber = intval(substr($lastTagihan->kode_tagihan, -4));
            $newNumber = $lastNumber + 1;
        } else {
            $newNumber = 1;
        }

        return $prefix . str_pad($newNumber, 4, '0', STR_PAD_LEFT);
    }
}
