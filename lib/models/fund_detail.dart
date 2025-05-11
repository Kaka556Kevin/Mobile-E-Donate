import 'package:intl/intl.dart';
import 'expense.dart';

class FundDetail {
  final int id;
  final String nama;
  final String deskripsi;
  final double target;
  final double collected;
  final double spent;
  final List<Expense> recentExpenses;

  FundDetail({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.target,
    required this.collected,
    required this.spent,
    required this.recentExpenses,
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) {
    return FundDetail(
      id: json['id'] as int,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      target: (json['target_terkumpul'] as num).toDouble(),
      collected: (json['jumlah_terkumpul'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      recentExpenses: (json['recent_expenses'] as List)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
        'target_terkumpul': target,
        'jumlah_terkumpul': collected,
        'spent': spent,
        'recent_expenses': recentExpenses.map((e) => e.toJson()).toList(),
      };

  String get collectedFormatted =>
      NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(collected);

  String get spentFormatted =>
      NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(spent);

  String get availableFormatted {
    final avail = collected - spent;
    return NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(avail);
  }
}
