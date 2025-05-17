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
    final labels = List<String>.from(json['labels'] ?? []);
    final rawValues = List<dynamic>.from(json['values'] ?? []);
    final values = rawValues.map((v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }).toList();

    final pts = <TimeSeriesPoint>[];
    for (var i = 0; i < labels.length && i < values.length; i++) {
      try {
        final dt = DateTime.parse(labels[i]);
        pts.add(TimeSeriesPoint(time: dt, value: values[i]));
      } catch (_) {
        // skip invalid date
      }
    }
    return DonationTrend(points: pts);
  }
}
