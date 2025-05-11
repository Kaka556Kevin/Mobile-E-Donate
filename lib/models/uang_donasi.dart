class UangDonasi {
  final int id;
  final String namaDonasi;
  final double uangMasuk;
  final double uangKeluar;

  UangDonasi({
    required this.id,
    required this.namaDonasi,
    required this.uangMasuk,
    required this.uangKeluar,
  });

  factory UangDonasi.fromJson(Map<String, dynamic> json) => UangDonasi(
        id: json['id'] as int,
        namaDonasi: json['nama_donasi'] as String,
        uangMasuk: (json['uang_masuk'] as num).toDouble(),
        uangKeluar: (json['uang_keluar'] as num).toDouble(),
      );

  double get saldo => uangMasuk - uangKeluar;
}
