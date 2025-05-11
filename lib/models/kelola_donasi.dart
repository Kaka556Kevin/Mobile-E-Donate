class KelolaDonasi {
  final String nama;
  final double donasiTerkumpul;

  KelolaDonasi({
    required this.nama,
    required this.donasiTerkumpul,
  });

  factory KelolaDonasi.fromJson(Map<String, dynamic> json) => KelolaDonasi(
        nama: json['nama'] as String,
        donasiTerkumpul: (json['donasi_terkumpul'] as num).toDouble(),
      );
}
