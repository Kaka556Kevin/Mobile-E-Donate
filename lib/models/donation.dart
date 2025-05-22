// lib/models/donation.dart

class Donation {
  final int id;
  final String nama;
  final String gambar;
  final String deskripsi;
  final double target;
  final double collected;
  final DateTime createdAt;

  // Tambahan
  final String? status;
  final List<Donatur>? donaturs;

  Donation({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.deskripsi,
    required this.target,
    required this.collected,
    required this.createdAt,
    this.status,
    this.donaturs,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    // Tangani target_terkumpul
    final rawTarget = json['target_terkumpul'];
    final parsedTarget = rawTarget == null
        ? 0.0
        : rawTarget is num
            ? rawTarget.toDouble()
            : double.tryParse(rawTarget.toString()) ?? 0.0;

    // Tangani collected (jika API menamainya berbeda)
    final rawCollected = json['collected'] ?? json['jumlah_terkumpul'];
    final parsedCollected = rawCollected == null
        ? 0.0
        : rawCollected is num
            ? rawCollected.toDouble()
            : double.tryParse(rawCollected.toString()) ?? 0.0;

    return Donation(
      id: json['id'] as int,
      nama: (json['nama'] as String?) ?? '',
      gambar: (json['gambar'] as String?) ?? '',
      deskripsi: (json['deskripsi'] as String?) ?? '',
      target: parsedTarget,
      collected: parsedCollected,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'],
      donaturs: json['donaturs'] != null
          ? (json['donaturs'] as List<dynamic>)
              .map((e) => Donatur.fromJson(e))
              .toList()
          : null,
    );
  }
}

class Donatur {
  final String nama;
  final int nominal;
  final DateTime? tanggal;

  Donatur({
    required this.nama,
    required this.nominal,
    this.tanggal,
  });

  factory Donatur.fromJson(Map<String, dynamic> json) {
    return Donatur(
      nama: json['nama'] ?? '-',
      nominal: int.tryParse(json['nominal'].toString()) ?? 0,
      tanggal: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
} 
