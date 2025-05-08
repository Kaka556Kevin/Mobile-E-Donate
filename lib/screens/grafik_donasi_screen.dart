// // lib/screens/grafik_donasi_screen.dart
// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import '../models/kelola_donasi.dart';
// import '../services/api_service.dart';

// class GrafikDonasiScreen extends StatefulWidget {
//   @override
//   _GrafikDonasiScreenState createState() => _GrafikDonasiScreenState();
// }

// class _GrafikDonasiScreenState extends State<GrafikDonasiScreen> {
//   late Future<List<KelolaDonasi>> _futureData;

//   @override
//   void initState() {
//     super.initState();
//     _futureData = ApiService().fetchKelolaDonasi();
//   }

//   List<charts.Series<KelolaDonasi, String>> _toSeries(List<KelolaDonasi> data) {
//     return [
//       charts.Series<KelolaDonasi, String>(
//         id: 'Donasi',
//         domainFn: (d, _) => d.nama,
//         measureFn: (d, _) => d.donasiTerkumpul.toInt(),
//         data: data,
//         labelAccessorFn: (d, _) => d.donasiTerkumpul.toString(),
//       )
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Grafik Donasi')),
//       body: FutureBuilder<List<KelolaDonasi>>(
//         future: _futureData,
//         builder: (ctx, snap) {
//           if (snap.hasData) {
//             return Padding(
//               padding: EdgeInsets.all(16),
//               child: charts.BarChart(
//                 _toSeries(snap.data!),
//                 animate: true,
//                 vertical: true,
//                 barRendererDecorator: charts.BarLabelDecorator<String>(),
//                 domainAxis: charts.OrdinalAxisSpec(),
//               ),
//             );
//           } else if (snap.hasError) {
//             return Center(child: Text('Error: ${snap.error}'));
//           }
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/kelola_donasi.dart';
import '../services/api_service.dart';

class GrafikDonasiScreen extends StatefulWidget {
  @override
  _GrafikDonasiScreenState createState() => _GrafikDonasiScreenState();
}

class _GrafikDonasiScreenState extends State<GrafikDonasiScreen> {
  late Future<List<KelolaDonasi>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = ApiService().fetchKelolaDonasi();
  }

  List<BarChartGroupData> _makeBarData(List<KelolaDonasi> data) {
    return data.asMap().entries.map((e) {
      final idx = e.key;
      final val = e.value.donasiTerkumpul.toDouble();
      return BarChartGroupData(
        x: idx,
        barRods: [BarChartRodData(toY: val, width: 16)],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      appBar: AppBar(title: Text('Grafik Donasi'), backgroundColor: headerColor),
      body: FutureBuilder<List<KelolaDonasi>>(
        future: _futureData,
        builder: (ctx, snap) {
          if (snap.hasData) {
            final data = snap.data!;
            return Padding(
              padding: EdgeInsets.all(16),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.map((d) => d.donasiTerkumpul).reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                  barGroups: _makeBarData(data),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= data.length) return SizedBox();
                          return Text(
                            data[idx].nama,
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            );
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
