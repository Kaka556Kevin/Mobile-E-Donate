// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedCampaign;
  late Future<List<Donation>> _futureDonations;

  @override
  void initState() {
    super.initState();
    _futureDonations = ApiService().fetchAllDonations();
  }

  List<FlSpot> _generateSpots(List<Donation> list) {
    final filtered = _selectedCampaign == null
        ? list
        : list.where((d) => d.nama == _selectedCampaign).toList();
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return filtered
        .map((d) => FlSpot(
              d.createdAt.millisecondsSinceEpoch.toDouble(),
              d.collected.toDouble(),
            ))
        .toList();
  }

  Future<void> _openReport() async {
    if (_selectedCampaign == null) return;
    final url = Uri.parse('https://dalitmayaan.com/api/donations/report?campaign=$_selectedCampaign');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka laporan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF4D5BFF);

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan'),
        backgroundColor: headerColor,
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }

          final donations = snapshot.data!;
          final campaigns = donations.map((d) => d.nama).toSet().toList();
          final spots = _generateSpots(donations);

          if (campaigns.isEmpty) {
            return Center(child: Text('Tidak ada data kampanye.'));
          }

          final minX = spots.isEmpty ? 0.0 : spots.first.x;
          final maxX = spots.isEmpty ? 0.0 : spots.last.x;
          final maxY = spots.isEmpty
              ? 0.0
              : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Pilih Kampanye',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  value: _selectedCampaign,
                  items: [null, ...campaigns]
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c ?? 'Semua Kampanye'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCampaign = v),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: spots.isEmpty
                      ? Center(child: Text('Pilih kampanye atau tunggu data.'))
                      : LineChart(
                          LineChartData(
                            minX: minX,
                            maxX: maxX,
                            minY: 0,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: spots.length > 1
                                      ? (maxX - minX) / (spots.length - 1)
                                      : 1.0,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                    return Text(
                                      DateFormat('dd/MM').format(dt),
                                      style: TextStyle(fontSize: 10),
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
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'Total Donasi',
                        value: donations
                            .map((d) => d.collected)
                            .fold(0.0, (sum, v) => sum + v)
                            .toInt()
                            .toString(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _InfoCard(
                        label: 'Rata-rata',
                        value: (donations
                                    .map((d) => d.collected)
                                    .fold(0.0, (sum, v) => sum + v) /
                                donations.length)
                            .round()
                            .toString(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: headerColor),
                    onPressed: _openReport,
                    child: Text('DOWNLOAD Laporan', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
