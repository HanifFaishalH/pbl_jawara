class AspirasiModel {
  final int aspirasiId;
  final int userId;
  final String pengirim;
  final String judul;
  final String deskripsi;
  final String status;
  final String? tanggapan;
  final String tanggalDibuat;
  final String? namaPenanggap; // <-- Field Baru

  AspirasiModel({
    required this.aspirasiId,
    required this.userId,
    required this.pengirim,
    required this.judul,
    required this.deskripsi,
    required this.status,
    this.tanggapan,
    required this.tanggalDibuat,
    this.namaPenanggap,
  });

  factory AspirasiModel.fromJson(Map<String, dynamic> json) {
    // 1. Ambil Nama Pengirim
    String namaPengirim = "Warga";
    if (json['user'] != null) {
      String depan = json['user']['user_nama_depan'] ?? '';
      String belakang = json['user']['user_nama_belakang'] ?? '';
      namaPengirim = "$depan $belakang".trim();
    }

    // 2. Ambil Nama Penanggap (Pejabat)
    String? penanggapFormatted;
    if (json['penanggap'] != null) {
      String namaPejabat = json['penanggap']['user_nama_depan'] ?? 'Pejabat';
      
      // Coba ambil nama role (misal: "Ketua RT")
      String roleLabel = "";
      if (json['penanggap']['role'] != null) {
         // Asumsi kolom nama role di database adalah 'role_nama'
         // Sesuaikan jika namanya 'role_name' atau 'nama_role'
         roleLabel = "(${json['penanggap']['role']['role_nama'] ?? 'Admin'})";
      }
      
      penanggapFormatted = "$namaPejabat $roleLabel".trim();
    }

    return AspirasiModel(
      aspirasiId: json['aspirasi_id'],
      userId: json['user_id'],
      pengirim: namaPengirim.isEmpty ? 'Unknown' : namaPengirim,
      judul: json['judul'] ?? 'Tanpa Judul',
      deskripsi: json['deskripsi'] ?? '-',
      status: json['status'] ?? 'Pending',
      tanggapan: json['tanggapan'],
      tanggalDibuat: json['created_at'] != null 
          ? json['created_at'].toString().substring(0, 10) 
          : '-',
      namaPenanggap: penanggapFormatted, // <-- Set field baru
    );
  }
}