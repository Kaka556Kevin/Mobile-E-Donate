// lib/models/uang_donasi.dart

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

  factory UangDonasi.fromJson(Map<String, dynamic> json) {
    final rawMasuk = json['uang_masuk'];
    final parsedMasuk = rawMasuk == null
        ? 0
        : rawMasuk is num
            ? rawMasuk.toInt()
            : int.tryParse(rawMasuk.toString()) ?? 0;

    final rawKeluar = json['uang_keluar'];
    final parsedKeluar = rawKeluar == null
        ? 0
        : rawKeluar is num
            ? rawKeluar.toInt()
            : int.tryParse(rawKeluar.toString()) ?? 0;

    return UangDonasi(
      id: json['id'] as int,
      namaDonasi: (json['nama_donasi'] as String?) ?? '',
      uangMasuk: parsedMasuk,
      uangKeluar: parsedKeluar,
    );
  }

  int get saldo => uangMasuk - uangKeluar;
}
