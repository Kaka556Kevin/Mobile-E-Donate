class Donation {
  final int id;
  final String nama;
  final String gambar;
  final String deskripsi;
  final double target;
  final double collected;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.deskripsi,
    required this.target,
    required this.collected,
    required this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    // Parsing target yang bisa berupa String atau num
    final rawTarget = json['target_terkumpul'];
    final rawCollected = json['collected'] ?? json['jumlah_terkumpul'];
    return Donation(
      id: json['id'] as int,
      nama: json['nama'] as String,
      gambar: json['gambar'] as String,
      deskripsi: json['deskripsi'] as String,
      target: rawTarget is String
          ? double.parse(rawTarget)
          : (rawTarget as num).toDouble(),
      collected: rawCollected is String
          ? double.parse(rawCollected)
          : (rawCollected as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
