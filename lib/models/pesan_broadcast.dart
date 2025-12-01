class PesanBroadcast {
  final int broadcastId;
  final String judul;
  final String isiPesan;
  final String tanggalKirim;
  final String? adminNama;

  PesanBroadcast({
    required this.broadcastId,
    required this.judul,
    required this.isiPesan,
    required this.tanggalKirim,
    this.adminNama,
  });

  factory PesanBroadcast.fromJson(Map<String, dynamic> json) {
    return PesanBroadcast(
      broadcastId: json['broadcast_id'],
      judul: json['judul'],
      isiPesan: json['isi_pesan'],
      tanggalKirim: json['tanggal_kirim'],
      adminNama: json['admin']?['user_nama_depan'],
    );
  }
}
