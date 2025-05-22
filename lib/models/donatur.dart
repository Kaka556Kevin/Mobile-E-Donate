class Donatur {
  final String nama;
  final int nominal;
  final DateTime? tanggal;

  Donatur({required this.nama, required this.nominal, this.tanggal});

  factory Donatur.fromJson(Map<String, dynamic> json) {
    return Donatur(
      nama: json['nama'],
      nominal: int.tryParse(json['nominal'].toString()) ?? 0,
      tanggal: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nominal': nominal,
      'created_at': tanggal?.toIso8601String(),
    };
  }
}
