// lib/screens/grafik_donasi_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class GrafikDonasiScreen extends StatefulWidget {
  @override
  _GrafikDonasiScreenState createState() => _GrafikDonasiScreenState();
}

class _GrafikDonasiScreenState extends State<GrafikDonasiScreen> {
  late Future<List<Donation>> _futureDonations;

  @override
  void initState() {
    super.initState();
    _futureDonations = ApiService().fetchAllDonations();
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> grouped) {
    final entries = grouped.entries.toList();
    return entries.asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      return BarChartGroupData(
        x: idx,
        barRods: [BarChartRodData(toY: entry.value, width: 16)],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      appBar: AppBar(title: Text('Grafik Donasi'), backgroundColor: headerColor),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          // group by campaign name and sum collected
          final Map<String, double> grouped = {};
          for (var d in data) {
            grouped[d.nama] = (grouped[d.nama] ?? 0) + d.collected;
          }
          final entries = grouped.entries.toList();
          final barGroups = _buildBarGroups(grouped);
          final maxY = grouped.values.reduce((a, b) => a > b ? a : b) * 1.2;

          return Padding(
            padding: EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) return SizedBox();
                        final name = entries[idx].key;
                        return Transform.translate(
                          offset: Offset(0, 4),
                          child: Text(name, style: TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          );
        },
      ),
    );
  }
}
