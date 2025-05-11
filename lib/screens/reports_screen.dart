import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/donation_trend.dart';
import '../models/kelola_donasi.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selected;
  List<String> _campaigns = [];
  Future<DonationTrend>? _futureTrend;

  @override
  void initState() {
    super.initState();
    ApiService().fetchKelolaDonasi().then((list) {
      setState(() => _campaigns = list.map((e) => e.nama).toList());
    });
  }

  void _onSelect(String? val) {
    setState(() {
      _selected = val;
      _futureTrend = ApiService().fetchDonationTrend(val!);
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      appBar: AppBar(title: Text('Laporan'), backgroundColor: headerColor),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Pilih Kampanye',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: _onSelect,
            ),
            SizedBox(height: 16),
            Expanded(
              child: _futureTrend == null
                  ? Center(child: Text('Pilih kampanye untuk melihat grafik'))
                  : FutureBuilder<DonationTrend>(
                      future: _futureTrend,
                      builder: (c, s) {
                        if (s.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                        if (s.hasError) return Center(child: Text('Error: ${s.error}'));
                        final pts = s.data!.points;
                        return LineChart(LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: pts.map((p) => FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value.toDouble())).toList(),
                              isCurved: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                                final dt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
                                return Text('${dt.day}/${dt.month}');
                              }),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
