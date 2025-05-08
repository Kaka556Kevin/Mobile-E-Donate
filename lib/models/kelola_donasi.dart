class KelolaDonasi {
  final String nama;
  final int donasiTerkumpul;

  KelolaDonasi({
    required this.nama,
    required this.donasiTerkumpul,
  });

  factory KelolaDonasi.fromJson(Map<String, dynamic> json) => KelolaDonasi(
        nama: json['nama'],
        donasiTerkumpul: int.parse(json['donasi_terkumpul'].toString()),
      );
}
