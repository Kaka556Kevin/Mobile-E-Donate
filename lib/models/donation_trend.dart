// lib/models/donation_trend.dart
class TimeSeriesPoint {
  final DateTime time;
  final int value;
  TimeSeriesPoint({ required this.time, required this.value });
}

class DonationTrend {
  final List<TimeSeriesPoint> points;
  DonationTrend({ required this.points });

  factory DonationTrend.fromJson(Map<String, dynamic> json) {
    final labels = List<String>.from(json['labels']);
    final values = List<num>.from(json['values']);
    final pts = List.generate(labels.length, (i) {
      return TimeSeriesPoint(
        time: DateTime.parse(labels[i]),
        value: values[i].toInt(),
      );
    });
    return DonationTrend(points: pts);
  }
}
