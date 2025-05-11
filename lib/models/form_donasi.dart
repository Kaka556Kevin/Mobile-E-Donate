class FormDonasi {
  final int id;
  final String nama;
  final String kontak;
  final double nominal;
  final DateTime createdAt;

  FormDonasi({
    required this.id,
    required this.nama,
    required this.kontak,
    required this.nominal,
    required this.createdAt,
  });

  factory FormDonasi.fromJson(Map<String, dynamic> json) => FormDonasi(
        id: json['id'] as int,
        nama: json['nama'] as String,
        kontak: json['kontak'] as String,
        nominal: (json['nominal'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
