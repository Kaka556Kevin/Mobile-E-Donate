class TimeSeriesPoint {
  final DateTime time;
  final double value;

  TimeSeriesPoint({ required this.time, required this.value });
}

class DonationTrend {
  final List<TimeSeriesPoint> points;

  DonationTrend({ required this.points });

  /// JSON structure: { "labels": ["2025-05-01",...], "values": [1000, ...] }
  factory DonationTrend.fromJson(Map<String, dynamic> json) {
    final labels = List<String>.from(json['labels'] as List);
    final values = List<num>.from(json['values'] as List);
    final pts = <TimeSeriesPoint>[];
    for (var i = 0; i < labels.length; i++) {
      pts.add(TimeSeriesPoint(
        time: DateTime.parse(labels[i]),
        value: values[i].toDouble(),
      ));
    }
    return DonationTrend(points: pts);
  }
}
