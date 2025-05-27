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

  factory FormDonasi.fromJson(Map<String, dynamic> json) {
    final rawNominal = json['nominal'];
    final parsedNominal = rawNominal == null
        ? 0
        : rawNominal is num
            ? rawNominal.toInt()
            : int.tryParse(rawNominal.toString()) ?? 0;

    return FormDonasi(
      id: json['id'] as int,
      tanggal: DateTime.parse(json['created_at'] as String),
      nama: (json['nama'] as String?) ?? '',
      nominal: parsedNominal,
      kontak: (json['kontak'] as String?) ?? '-',
    );
  }
}