// // import 'package:flutter/material.dart';
// // import 'package:charts_flutter/flutter.dart' as charts;
// // import '../services/api_service.dart';

// // class ReportsScreen extends StatefulWidget {
// //   @override
// //   _ReportsScreenState createState() => _ReportsScreenState();
// // }

// // class _ReportsScreenState extends State<ReportsScreen> {
// //   String? _selectedCampaign;
// //   List<String> _campaigns = [];
// //   late Future<DonationTrend> _futureTrend;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // ambil list campaign utk dropdown
// //     ApiService().fetchCampaignNames().then((list) {
// //       setState(() => _campaigns = list);
// //     });
// //   }

// //   void _loadTrend() {
// //     if (_selectedCampaign != null) {
// //       setState(() {
// //         _futureTrend = ApiService().fetchDonationTrend(_selectedCampaign!);
// //       });
// //     }
// //   }

// //   List<charts.Series<TimeSeriesPoint, DateTime>> _makeSeries(DonationTrend data) {
// //     return [
// //       charts.Series<TimeSeriesPoint, DateTime>(
// //         id: 'Trend',
// //         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
// //         domainFn: (p, _) => p.time,
// //         measureFn: (p, _) => p.value,
// //         data: data.points,
// //       )
// //     ];
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     const headerColor = Color(0xFF4D5BFF);

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.stretch,
// //       children: [
// //         Container(
// //           color: headerColor,
// //           padding: EdgeInsets.only(top: 48, bottom: 24, left: 24),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text('Laporan',
// //                   style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
// //               SizedBox(height: 4),
// //               Text('Analisa Donasi', style: TextStyle(color: Colors.white70)),
// //             ],
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Padding(
// //           padding: EdgeInsets.symmetric(horizontal: 16),
// //           child: DropdownButtonFormField<String>(
// //             decoration: InputDecoration(
// //               hintText: 'Filter Donasi',
// //               filled: true,
// //               fillColor: Colors.white,
// //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// //               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //             ),
// //             items: _campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
// //             onChanged: (v) => setState(() => _selectedCampaign = v),
// //             onSaved: (_) => _loadTrend(),
// //             onTap: _loadTrend,
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Expanded(
// //           child: FutureBuilder<DonationTrend>(
// //             future: _futureTrend,
// //             builder: (ctx, snap) {
// //               if (snap.hasData) {
// //                 final trend = snap.data!;
// //                 return Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 16),
// //                   child: Container(
// //                     padding: EdgeInsets.all(12),
// //                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
// //                     child: charts.TimeSeriesChart(
// //                       _makeSeries(trend),
// //                       animate: true,
// //                       domainAxis: charts.DateTimeAxisSpec(
// //                         tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
// //                           month: charts.TimeFormatterSpec(format: 'MMM', transitionFormat: 'MMM'),
// //                         ),
// //                       ),
// //                       primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
// //                     ),
// //                   ),
// //                 );
// //               } else if (snap.hasError) {
// //                 return Center(child: Text('Error: ${snap.error}'));
// //               }
// //               return Center(child: Text('Pilih kampanye untuk melihat grafik.'));
// //             },
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Padding(
// //           padding: EdgeInsets.symmetric(horizontal: 16),
// //           child: Row(
// //             children: [
// //               _infoCard('Total Donasi', '${snapDataCount(_futureTrend)}'),
// //               _infoCard('Rata-rata', 'Rp ${snapDataAvg(_futureTrend)}'),
// //             ],
// //           ),
// //         ),
// //         SizedBox(height: 24),
// //         Padding(
// //           padding: EdgeInsets.symmetric(horizontal: 16),
// //           child: SizedBox(
// //             width: double.infinity,
// //             height: 48,
// //             child: ElevatedButton(
// //               style: ElevatedButton.styleFrom(primary: headerColor),
// //               onPressed: () {
// //                 // misal: download via ApiService().downloadReport(...)
// //               },
// //               child: Text('DOWNLOAD Laporan', style: TextStyle(color: Colors.white)),
// //             ),
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //       ],
// //     );
// //   }

// //   Widget _infoCard(String label, String value) {
// //     return Expanded(
// //       child: Container(
// //         margin: EdgeInsets.symmetric(horizontal: 4),
// //         padding: EdgeInsets.all(12),
// //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(label, style: TextStyle(color: Colors.grey[600])),
// //             SizedBox(height: 8),
// //             Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   /// helper untuk mengambil count dan rata-rata dari DonationTrend
// //   String snapDataCount(Future<DonationTrend> f) => '—'; // implement sesuai kebutuhan
// //   String snapDataAvg(Future<DonationTrend> f) => '—';   // implement sesuai kebutuhan
// // }

// // /// Model untuk grafik
// // class TimeSeriesPoint {
// //   final DateTime time;
// //   final int value;
// //   TimeSeriesPoint(this.time, this.value);
// // }

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../models/donation_trend.dart';
// import '../services/api_service.dart';

// class ReportsScreen extends StatefulWidget {
//   @override
//   _ReportsScreenState createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _sel;
//   List<String> _list = [];
//   late Future<DonationTrend> _future;

//   @override
//   void initState() {
//     super.initState();
//     ApiService().fetchKelolaDonasi().then((l) => setState(() => _list = l));
//   }

//   void _load() {
//     if (_sel != null) {
//       setState(() => _future = ApiService().fetchDonationTrend(_sel!));
//     }
//   }

//   List<FlSpot> _spots(List<TimeSeriesPoint> pts) =>
//       pts.map((p) => FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value.toDouble())).toList();

//   @override
//   Widget build(BuildContext ctx) {
//     const headerColor = Color(0xFF4D5BFF);
//     return Scaffold(
//       appBar: AppBar(title: Text('Laporan'), backgroundColor: headerColor),
//       body: Column(
//         children: [
//           SizedBox(height: 16),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 hintText: 'Filter Donasi',
//                 filled: true, fillColor: Colors.white,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               items: _list.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//               onChanged: (v) => setState(() => _sel = v),
//               onSaved: (_) => _load(),
//               onTap: _load,
//             ),
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: FutureBuilder<DonationTrend>(
//               future: _future,
//               builder: (c, s) {
//                 if (s.hasData) {
//                   final pts = s.data!.points;
//                   return Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: LineChart(
//                       LineChartData(
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: _spots(pts),
//                             isCurved: true,
//                             barWidth: 3,
//                             dotData: FlDotData(show: false),
//                           ),
//                         ],
//                         titlesData: FlTitlesData(
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               interval: pts.length > 1
//                                   ? (pts.last.time.millisecondsSinceEpoch - pts.first.time.millisecondsSinceEpoch) /
//                                       (pts.length - 1)
//                                   : 1,
//                               getTitlesWidget: (v, _) {
//                                 final dt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
//                                 return Text(
//                                   ['Jan','Feb','Mar','Apr','May','Jun','Jul'][dt.month - 1],
//                                   style: TextStyle(fontSize: 10),
//                                 );
//                               },
//                             ),
//                           ),
//                           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         },
//                         gridData: FlGridData(show: false),
//                         borderData: FlBorderData(show: false),
//                       ),
//                     ),
//                   );
//                 } else if (s.hasError) return Center(child: Text('Error'));
//                 return Center(child: Text('Pilih kampanye untuk lihat grafik'));
//               },
//             ),
//           ),
//           SizedBox(height: 16),
//           // TODO: hitung total & rata-rata dari s.data!.points
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 _infoCard('Total Donasi', '—'),
//                 _infoCard('Rata-rata', '—'),
//               ],
//             ),
//           ),
//           SizedBox(height: 24),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: headerColor),
//                 onPressed: () => ApiService().downloadReport(_sel!),
//                 child: Text('DOWNLOAD Laporan'),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _infoCard(String label, String value) => Expanded(
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 4),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: TextStyle(color: Colors.grey[600])),
//               SizedBox(height: 8),
//               Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       );
// }

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../models/donation_trend.dart';
// import '../services/api_service.dart';
// import '../models/kelola_donasi.dart'; // untuk model KelolaDonasi

// class ReportsScreen extends StatefulWidget {
//   @override
//   _ReportsScreenState createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   String? _sel;
//   List<String> _list = [];
//   late Future<DonationTrend> _future;

//   @override
//   void initState() {
//     super.initState();
//     ApiService()
//     .fetchKelolaDonasi()
//     .then((list) {
//       setState(() {
//         _list = list.map((k) => k.nama).toList();
//       });
//     })
//     .catchError((e) {
//       debugPrint('Error fetchKelolaDonasi: $e');
//       // kembalikan list kosong supaya callback then tetap bernilai List<KelolaDonasi>
//       return <KelolaDonasi>[];
//     });
//   }

//   void _load() {
//     if (_sel != null) {
//       setState(() {
//         _future = ApiService().fetchDonationTrend(_sel!);
//       });
//     }
//   }

//   List<FlSpot> _spots(List<TimeSeriesPoint> pts) =>
//       pts.map((p) => FlSpot(
//             p.time.millisecondsSinceEpoch.toDouble(),
//             p.value.toDouble(),
//           )).toList();

//   @override
//   Widget build(BuildContext ctx) {
//     const headerColor = Color(0xFF4D5BFF);
//     return Scaffold(
//       appBar: AppBar(title: Text('Laporan'), backgroundColor: headerColor),
//       body: Column(
//         children: [
//           SizedBox(height: 16),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 hintText: 'Filter Donasi',
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               items: _list
//                   .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                   .toList(),
//               onChanged: (v) {
//                 setState(() {
//                   _sel = v;
//                 });
//                 _load();
//               },
//             ),
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: FutureBuilder<DonationTrend>(
//               future: _future,
//               builder: (c, s) {
//                 if (s.hasData) {
//                   final pts = s.data!.points;
//                   return Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: LineChart(
//                       LineChartData(
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: _spots(pts),
//                             isCurved: true,
//                             barWidth: 3,
//                             dotData: FlDotData(show: false),
//                           ),
//                         ],
//                         titlesData: FlTitlesData(
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               interval: pts.length > 1
//                                   ? (pts.last.time.millisecondsSinceEpoch - pts.first.time.millisecondsSinceEpoch) / (pts.length - 1)
//                                   : 1,
//                               getTitlesWidget: (v, _) {
//                                 final dt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
//                                 return Text(
//                                   ['Jan','Feb','Mar','Apr','May','Jun','Jul'][dt.month - 1],
//                                   style: TextStyle(fontSize: 10),
//                                 );
//                               },
//                             ),
//                           ),
//                           leftTitles: AxisTitles(
//                               sideTitles: SideTitles(showTitles: false)),
//                         ),
//                         gridData: FlGridData(show: false),
//                         borderData: FlBorderData(show: false),
//                       ),
//                     ),
//                   );
//                 } else if (s.hasError) {
//                   return Center(child: Text('Error: \${s.error}'));
//                 }
//                 return Center(child: Text('Pilih kampanye untuk lihat grafik'));
//               },
//             ),
//           ),
//           SizedBox(height: 16),
//           // TODO: hitung total & rata-rata dari s.data!.points jika diperlukan
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 _infoCard('Total Donasi', '—'),
//                 _infoCard('Rata-rata', '—'),
//               ],
//             ),
//           ),
//           SizedBox(height: 24),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: headerColor),
//                 onPressed: () => ApiService().downloadReport(_sel!),
//                 child: Text('DOWNLOAD Laporan', style: TextStyle(color: Colors.white)),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _infoCard(String label, String value) => Expanded(
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 4),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: TextStyle(color: Colors.grey[600])),
//               SizedBox(height: 8),
//               Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       );
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/donation_trend.dart';
import '../services/api_service.dart';
// model KelolaDonasi 

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _sel;
  List<String> _list = [];
  late Future<DonationTrend> _future;

  @override
  void initState() {
    super.initState();
    ApiService().fetchKelolaDonasi().then((list) {
      setState(() {
        // convert List<KelolaDonasi> to List<String>
        _list = list.map((k) => k.nama).toList();
      });
    }).catchError((e) {
      debugPrint('Error fetchKelolaDonasi: $e');
    });
  }

  void _load() {
    if (_sel != null) {
      setState(() {
        _future = ApiService().fetchDonationTrend(_sel!);
      });
    }
  }

  List<FlSpot> _spots(List<TimeSeriesPoint> pts) => pts
      .map((p) => FlSpot(
            p.time.millisecondsSinceEpoch.toDouble(),
            p.value.toDouble(),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      appBar: AppBar(title: Text('Laporan'), backgroundColor: headerColor),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Filter Donasi',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _list
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                _sel = v;
                _load();
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: (_sel == null)
                ? Center(child: Text('Pilih kampanye untuk lihat grafik'))
                : FutureBuilder<DonationTrend>(
                    future: _future,
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snap.hasError) {
                        return Center(child: Text('Error: \${snap.error}'));
                      } else if (!snap.hasData) {
                        return Center(child: Text('Data kosong'));
                      }
                      final pts = snap.data!.points;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _spots(pts),
                                isCurved: true,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: pts.length > 1
                                      ? (pts.last.time.millisecondsSinceEpoch -
                                              pts.first.time
                                                  .millisecondsSinceEpoch) /
                                          (pts.length - 1)
                                      : 1,
                                  getTitlesWidget: (v, _) {
                                    final dt =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            v.toInt());
                                    return Text(
                                      [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul'
                                      ][dt.month - 1],
                                      style: TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _infoCard('Total Donasi', '—'),
                _infoCard('Rata-rata', '—'),
              ],
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: headerColor),
                onPressed: _sel == null
                    ? null
                    : () => ApiService().downloadReport(_sel!),
                child: Text('DOWNLOAD Laporan',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) => Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
              Text(value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
}
