<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\KategoriModel;

class KategoriController extends Controller
{
    // GET /api/kategori (public)
    public function index(Request $request)
    {
        $q = KategoriModel::query();
        if ($request->filled('search')) {
            $term = (string) $request->get('search');
            $q->where('kategori_nama', 'like', "%{$term}%")
              ->orWhere('kategori_kode', 'like', "%{$term}%");
        }
        $q->orderBy('kategori_nama');
        return response()->json(['data' => $q->get()]);
    }
}
