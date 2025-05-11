import 'dart:convert';

class Donation {
  final int id;
  final String nama;
  final String deskripsi;
  final String gambar;         // path atau URL
  final double target;         // target_terkumpul
  final double collected;      // terkumpul
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.gambar,
    required this.target,
    required this.collected,
    required this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as int,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      gambar: json['gambar'] as String,
      target: (json['target_terkumpul'] as num).toDouble(),
      collected: (json['terkumpul'] as num? ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
        'gambar': gambar,
        'target_terkumpul': target,
        'terkumpul': collected,
      };
}
