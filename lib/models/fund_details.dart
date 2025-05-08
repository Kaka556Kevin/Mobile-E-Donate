// lib/models/fund_detail.dart
class Expense {
  final String description;
  final DateTime date;
  final int amount;

  Expense({
    required this.description,
    required this.date,
    required this.amount,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        description: json['description'],
        date: DateTime.parse(json['date']),
        amount: int.parse(json['amount'].toString()),
      );

  String get dateFormatted => '${date.month}/${date.day}/${date.year}';
  String get amountFormatted => amount.toString();
}

class FundDetail {
  final int collected;
  final int spent;
  final List<Expense> recentExpenses;

  FundDetail({
    required this.collected,
    required this.spent,
    required this.recentExpenses,
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) => FundDetail(
        collected: int.parse(json['collected'].toString()),
        spent: int.parse(json['spent'].toString()),
        recentExpenses: (json['recent_expenses'] as List)
            .map((e) => Expense.fromJson(e))
            .toList(),
      );

  int get available => collected - spent;
}
