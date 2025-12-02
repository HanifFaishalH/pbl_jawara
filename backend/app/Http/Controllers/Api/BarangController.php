<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\BarangModel;

class BarangController extends Controller
{
    // GET /api/barang
    public function index(Request $request)
    {
        $q = BarangModel::query()->with('user');
        if ($request->filled('search')) {
            $term = (string) $request->get('search');
            $q->where('barang_nama', 'like', "%{$term}%");
        }
        $q->latest('barang_id');
        return response()->json($q->paginate(10));
    }

    // GET /api/barang/user (auth)
    public function indexUser(Request $request)
    {
        $user = $request->user();
        $items = BarangModel::where('user_id', $user->user_id)->orderByDesc('barang_id')->get();
        return response()->json(['data' => $items]);
    }

    // GET /api/barang/{id}
    public function show($id)
    {
        $item = BarangModel::where('barang_id', $id)->firstOrFail();
        return response()->json($item);
    }

    // POST /api/barang (auth) - multipart/form-data supported
    public function store(Request $request)
    {
        $validated = $request->validate([
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id',
            'barang_nama' => 'required|string|max:150',
            'barang_deskripsi' => 'nullable|string',
            'barang_harga' => 'required|integer|min:0',
            'barang_stok' => 'nullable|integer|min:0',
            'foto' => 'nullable|image|max:4096',
        ]);

        $data = $validated;
        $data['user_id'] = $request->user()->user_id;
        // generate kode jika tidak dikirim
        $data['barang_kode'] = 'BRG-' . now()->format('YmdHis') . '-' . random_int(100, 999);

        if ($request->hasFile('foto')) {
            $path = $request->file('foto')->store('barang', 'public');
            $data['barang_foto'] = $path;
        }

        $item = BarangModel::create($data);
        return response()->json(['message' => 'Barang ditambahkan', 'data' => $item], 201);
    }

    // PUT/PATCH /api/barang/{id}
    public function update(Request $request, $id)
    {
        $item = BarangModel::where('barang_id', $id)->firstOrFail();
        $this->authorizeOwner($request->user()->user_id, $item->user_id);

        $validated = $request->validate([
            'kategori_id' => 'nullable|exists:m_kategori,kategori_id',
            'barang_nama' => 'sometimes|required|string|max:150',
            'barang_deskripsi' => 'nullable|string',
            'barang_harga' => 'sometimes|required|integer|min:0',
            'barang_stok' => 'nullable|integer|min:0',
            'foto' => 'nullable|image|max:4096',
        ]);

        $data = $validated;
        if ($request->hasFile('foto')) {
            if ($item->barang_foto) {
                Storage::disk('public')->delete($item->barang_foto);
            }
            $path = $request->file('foto')->store('barang', 'public');
            $data['barang_foto'] = $path;
        }

        $item->update($data);
        return response()->json(['message' => 'Barang diperbarui', 'data' => $item]);
    }

    // DELETE /api/barang/{id}
    public function destroy(Request $request, $id)
    {
        $item = BarangModel::where('barang_id', $id)->firstOrFail();
        $this->authorizeOwner($request->user()->user_id, $item->user_id);
        if ($item->barang_foto) {
            Storage::disk('public')->delete($item->barang_foto);
        }
        $item->delete();
        return response()->json(['message' => 'Barang dihapus']);
    }

    private function authorizeOwner($currentUserId, $ownerId)
    {
        abort_if($currentUserId !== $ownerId, 403, 'Tidak diizinkan');
    }
}