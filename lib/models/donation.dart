// lib/models/donation.dart

import 'package:intl/intl.dart';

class Donation {
  final int id;
  final String nama;
  final String gambar;
  final String deskripsi;
  final double target;
  final double collected;
  final DateTime createdAt;
  final DateTime? deadline;
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
    this.deadline,
    this.status,
    this.donaturs,
  });

  // [FIX] Normalisasi tanggal (Hanya Year, Month, Day)
  DateTime _toDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool get isClosed {
    if (deadline == null) return false;
    // Jika hari ini > deadline (besoknya), maka ditutup
    return _toDate(DateTime.now()).isAfter(_toDate(deadline!));
  }

  String get sisaWaktuText {
    if (deadline == null) return "Tanpa batas waktu";
    
    final dateNow = _toDate(DateTime.now());
    final dateDeadline = _toDate(deadline!);

    // Jika sudah lewat (misal deadline kemarin)
    if (dateNow.isAfter(dateDeadline)) {
      return "Status: Donasi sudah ditutup";
    }

    final diff = dateDeadline.difference(dateNow).inDays;

    if (diff == 0) {
      return "Sisa waktu: Hari ini terakhir";
    } else {
      return "Sisa waktu: $diff hari lagi";
    }
  }

  int get sisaHari {
    if (deadline == null) return 999;
    return _toDate(deadline!).difference(_toDate(DateTime.now())).inDays;
  }

  String get shareSummary {
    final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final timeStatus = isClosed ? "Sudah Ditutup" : sisaWaktuText.replaceAll("Sisa waktu: ", "");
    
    return '''
Halo! Berikut update donasi terkini:

📢 *${nama}*
💰 Terkumpul: ${currencyFmt.format(collected)}
🎯 Target: ${currencyFmt.format(target)}
⏳ Waktu: $timeStatus
📊 Status: ${status ?? 'Aktif'}

Terima kasih atas partisipasi Anda!
''';
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    final parsedTarget = parseDouble(json['target_terkumpul'] ?? json['target']);
    final parsedCollected = parseDouble(json['donasi_terkumpul'] ?? json['donasiTerkumpul'] ?? json['collected']);
    final parsedCreated = DateTime.parse(json['created_at'] as String);
    
    DateTime? parsedDeadline;
    if (json['tenggat_waktu_donasi'] != null) {
      parsedDeadline = DateTime.tryParse(json['tenggat_waktu_donasi'].toString());
    } else if (json['deadline'] != null) {
      parsedDeadline = DateTime.tryParse(json['deadline'].toString());
    } else {
      parsedDeadline = parsedCreated.add(const Duration(days: 30));
    }

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
      createdAt: parsedCreated,
      deadline: parsedDeadline,
      status: json['status'] as String?,
      donaturs: donaturs,
    );
  }
}

// ... Class Donatur tetap sama
class Donatur {
  final String nama;
  final double nominal;
  final DateTime? tanggal;

  Donatur({required this.nama, required this.nominal, this.tanggal});

  factory Donatur.fromJson(Map<String, dynamic> json) {
    final parsedNominal = json['nominal'] is num
        ? (json['nominal'] as num).toDouble()
        : double.tryParse(json['nominal'].toString()) ?? 0.0;
    
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString());
    }

    return Donatur(
      nama: (json['nama'] as String?) ?? 'Hamba Allah',
      nominal: parsedNominal,
      tanggal: parsedDate,
    );
  }
}