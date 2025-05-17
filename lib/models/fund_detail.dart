// lib/models/fund_detail.dart

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
    int parseInt(dynamic raw) => raw == null
        ? 0
        : raw is num
            ? raw.toInt()
            : int.tryParse(raw.toString()) ?? 0;

    return FundDetail(
      id: json['id'] as int,
      nama: (json['nama'] as String?) ?? '',
      deskripsi: (json['deskripsi'] as String?) ?? '',
      targetTerkumpul: parseInt(json['target_terkumpul']),
      jumlahTerkumpul: parseInt(json['jumlah_terkumpul']),
      tanggalDibuat: DateTime.parse(json['tanggal_dibuat'] as String),
      gambarUrl: (json['gambar_url'] as String?) ?? '',
      spent: parseInt(json['spent']),
      recentExpenses: (json['recent_expenses'] as List<dynamic>?)
              ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Getters untuk format UI...
}
