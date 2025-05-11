import 'package:intl/intl.dart';
import 'dart:io';

class Expense {
  final int id;
  final String description;
  final DateTime date;
  final double amount;

  Expense({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as int,
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'date': date.toIso8601String(),
        'amount': amount,
      };

  String get dateFormatted => DateFormat.yMMMMd('id_ID').format(date);
  String get amountFormatted => NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
}
