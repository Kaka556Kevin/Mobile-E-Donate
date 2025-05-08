class UangDonasi {
  final int id;
  final String namaDonasi;
  final int uangMasuk;
  final int uangKeluar;

  UangDonasi({
    required this.id,
    required this.namaDonasi,
    required this.uangMasuk,
    required this.uangKeluar,
  });

  factory UangDonasi.fromJson(Map<String, dynamic> json) => UangDonasi(
        id: json['id'],
        namaDonasi: json['nama_donasi'],
        uangMasuk: int.parse(json['uang_masuk'].toString()),
        uangKeluar: int.parse(json['uang_keluar'].toString()),
      );

  int get saldo => uangMasuk - uangKeluar;
}
