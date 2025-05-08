class FormDonasi {
  final int id;
  final DateTime tanggal;
  final String nama;
  final int nominal;
  final String kontak;

  FormDonasi({
    required this.id,
    required this.tanggal,
    required this.nama,
    required this.nominal,
    required this.kontak,
  });

  factory FormDonasi.fromJson(Map<String, dynamic> json) => FormDonasi(
        id: json['id'],
        tanggal: DateTime.parse(json['created_at']),
        nama: json['nama'],
        nominal: int.parse(json['nominal'].toString()),
        kontak: json['kontak'],
      );
}
