// lib/models/kelola_donasi.dart

class KelolaDonasi {
  final String nama;
  final int donasiTerkumpul;

  KelolaDonasi({
    required this.nama,
    required this.donasiTerkumpul,
  });

  factory KelolaDonasi.fromJson(Map<String, dynamic> json) {
    final raw = json['donasi_terkumpul'];
    final parsed = raw == null
        ? 0
        : raw is num
            ? raw.toInt()
            : int.tryParse(raw.toString()) ?? 0;

    return KelolaDonasi(
      nama: (json['nama'] as String?) ?? '',
      donasiTerkumpul: parsed,
    );
  }
}
