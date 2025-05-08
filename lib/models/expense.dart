// // lib/models/expense.dart

// class Expense {
//   final int id;
//   final String description;
//   final DateTime date;
//   final int amount;

//   Expense({
//     required this.id,
//     required this.description,
//     required this.date,
//     required this.amount,
//   });

//   factory Expense.fromJson(Map<String, dynamic> json) {
//     return Expense(
//       id: json['id'] as int,
//       description: json['description'] as String,
//       date: DateTime.parse(json['date'] as String),
//       amount: int.parse(json['amount'].toString()),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'description': description,
//       'date': date.toIso8601String(),
//       'amount': amount,
//     };
//   }
// }

import 'package:intl/intl.dart';

class Expense {
  final int id;
  final String description;
  final DateTime date;
  final int amount;

  Expense({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: int.parse(json['amount'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  // Computed getters untuk UI
  String get dateFormatted => DateFormat.yMMMMd('en_US').format(date);

  String get amountFormatted => NumberFormat.compact(locale: 'en_US').format(amount);
}
