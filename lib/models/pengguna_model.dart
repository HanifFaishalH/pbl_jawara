class PenggunaModel {
  final int userId;
  final String nama;
  final String email;
  final String status;
  final int roleId;
  
  // Field tambahan untuk keperluan Edit Form
  final String namaDepan;
  final String namaBelakang;
  final String tglLahir;
  final String alamat;

  PenggunaModel({
    required this.userId,
    required this.nama,
    required this.email,
    required this.status,
    required this.roleId,
    required this.namaDepan,
    required this.namaBelakang,
    required this.tglLahir,
    required this.alamat,
  });

  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    // Logic fallback nama
    String displayName = 'Tanpa Nama';
    if (json['nama'] != null && json['nama'].toString().isNotEmpty) {
      displayName = json['nama'];
    } else {
      String d = json['user_nama_depan'] ?? '';
      String b = json['user_nama_belakang'] ?? '';
      displayName = "$d $b".trim();
    }

    return PenggunaModel(
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      nama: displayName,
      email: json['email'] ?? '-',
      status: json['status'] ?? 'Pending',
      roleId: int.tryParse(json['role_id'].toString()) ?? 0,
      
      // Data mentah untuk form edit
      namaDepan: json['user_nama_depan'] ?? '',
      namaBelakang: json['user_nama_belakang'] ?? '',
      tglLahir: json['user_tanggal_lahir'] ?? '', // Pastikan controller kirim ini
      alamat: json['user_alamat'] ?? '',          // Pastikan controller kirim ini
    );
  }
}