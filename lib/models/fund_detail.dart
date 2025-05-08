// // lib/models/fund_detail.dart

// import 'dart:convert';

// class FundDetail {
//   final int id;
//   final String nama;
//   final String deskripsi;
//   final int targetTerkumpul;
//   final int jumlahTerkumpul;
//   final DateTime tanggalDibuat;
//   final String gambarUrl;

//   FundDetail({
//     required this.id,
//     required this.nama,
//     required this.deskripsi,
//     required this.targetTerkumpul,
//     required this.jumlahTerkumpul,
//     required this.tanggalDibuat,
//     required this.gambarUrl,
//   });

//   factory FundDetail.fromJson(Map<String, dynamic> json) {
//     return FundDetail(
//       id: json['id'],
//       nama: json['nama'],
//       deskripsi: json['deskripsi'],
//       targetTerkumpul: json['target_terkumpul'],
//       jumlahTerkumpul: json['jumlah_terkumpul'],
//       tanggalDibuat: DateTime.parse(json['tanggal_dibuat']),
//       gambarUrl: json['gambar_url'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'nama': nama,
//       'deskripsi': deskripsi,
//       'target_terkumpul': targetTerkumpul,
//       'jumlah_terkumpul': jumlahTerkumpul,
//       'tanggal_dibuat': tanggalDibuat.toIso8601String(),
//       'gambar_url': gambarUrl,
//     };
//   }
// }

import 'package:intl/intl.dart';
import 'expense.dart';

class FundDetail {
  final int id;
  final String nama;
  final String deskripsi;
  final int targetTerkumpul;
  final int jumlahTerkumpul;
  final DateTime tanggalDibuat;
  final String gambarUrl;
  final int spent;
  final List<Expense> recentExpenses;

  FundDetail({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.targetTerkumpul,
    required this.jumlahTerkumpul,
    required this.tanggalDibuat,
    required this.gambarUrl,
    required this.spent,
    required this.recentExpenses,
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) {
    return FundDetail(
      id: json['id'] as int,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      targetTerkumpul: json['target_terkumpul'] as int,
      jumlahTerkumpul: json['jumlah_terkumpul'] as int,
      tanggalDibuat: DateTime.parse(json['tanggal_dibuat'] as String),
      gambarUrl: json['gambar_url'] as String,
      spent: json['spent'] as int,
      recentExpenses: (json['recent_expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'target_terkumpul': targetTerkumpul,
      'jumlah_terkumpul': jumlahTerkumpul,
      'tanggal_dibuat': tanggalDibuat.toIso8601String(),
      'gambar_url': gambarUrl,
      'spent': spent,
      'recent_expenses': recentExpenses.map((e) => e.toJson()).toList(),
    };
  }

  // Computed getters untuk UI
  String get collectedFormatted =>
      NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(jumlahTerkumpul);

  String get spentFormatted =>
      NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(spent);

  String get availableFormatted {
    final avail = jumlahTerkumpul - spent;
    return NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(avail);
  }
}
