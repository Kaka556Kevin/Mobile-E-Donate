// lib/models/donation.dart


class Donation {
  final int id;
  final String nama;
  final String gambar;
  final String deskripsi;
  final double target;
  final double collected;
  final DateTime createdAt;
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
    final rawTarget = json['target_terkumpul'] ?? json['target'];
    final parsedTarget = rawTarget == null
        ? 0.0
        : rawTarget is num
            ? rawTarget.toDouble()
            : double.tryParse(rawTarget.toString()) ?? 0.0;

    // Tangani donasi_terkumpul dari API
    final rawCollected = json['donasi_terkumpul'] ?? json['donasiTerkumpul'] ?? json['collected'];
    final parsedCollected = rawCollected == null
        ? 0.0
        : rawCollected is num
            ? rawCollected.toDouble()
            : double.tryParse(rawCollected.toString()) ?? 0.0;

    // Tangani status (jika ada)
    final status = json['status'] as String?;

    // Tangani daftar donatur
    List<Donatur>? donaturs;
    if (json['donaturs'] != null && json['donaturs'] is List) {
      donaturs = (json['donaturs'] as List<dynamic>)
          .map((e) => Donatur.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Donation(
      id: json['id'] as int,
      nama: (json['nama'] as String?) ?? '',
      gambar: (json['gambar'] as String?) ?? '',
      deskripsi: (json['deskripsi'] as String?) ?? '',
      target: parsedTarget,
      collected: parsedCollected,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: status,
      donaturs: donaturs,
    );
  }
}

class Donatur {
  final String nama;
  final double nominal;
  final DateTime? tanggal;

  Donatur({
    required this.nama,
    required this.nominal,
    this.tanggal,
  });

  factory Donatur.fromJson(Map<String, dynamic> json) {
    final parsedNominal = json['nominal'] is num
        ? (json['nominal'] as num).toDouble()
        : double.tryParse(json['nominal'].toString()) ?? 0.0;

    DateTime? parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'] as String);
    }

    return Donatur(
      nama: (json['nama'] as String?) ?? '-',
      nominal: parsedNominal,
      tanggal: parsedDate,
    );
  }
}
