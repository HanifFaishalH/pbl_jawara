class PesanWarga {
  final int pesanId;
  final int pengirimId;
  final int penerimaId;
  final String isiPesan;
  final bool dibaca;
  final String createdAt;
  final String? pengirimNama;
  final String? penerimaNama;

  PesanWarga({
    required this.pesanId,
    required this.pengirimId,
    required this.penerimaId,
    required this.isiPesan,
    required this.dibaca,
    required this.createdAt,
    this.pengirimNama,
    this.penerimaNama,
  });

  factory PesanWarga.fromJson(Map<String, dynamic> json) {
    return PesanWarga(
      pesanId: (json['pesan_id'] ?? 0) as int,
      pengirimId: (json['pengirim_id'] ?? 0) as int,
      penerimaId: (json['penerima_id'] ?? 0) as int,
      isiPesan: (json['isi_pesan'] ?? '').toString(),
      dibaca: json['dibaca'] == 1 || json['dibaca'] == true,
      createdAt: (json['created_at'] ?? '').toString(),
      pengirimNama: json['pengirim']?['user_nama_depan'],
      penerimaNama: json['penerima']?['user_nama_depan'],
    );
  }
}
