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

  Future<void> _openReport() async {
    if (_selectedCampaign == null) return;
    final url = Uri.parse(
        'https://dalitmayaan.com/api/donations/report?campaign=$_selectedCampaign');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal membuka laporan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF4D5BFF);

    return Scaffold(
      appBar: AppBar(
        title: Text('Grafik Donasi'),
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

          final data = snapshot.data!;
          final campaigns = data.map((d) => d.nama).toSet().toList();
          if (campaigns.isEmpty) {
            return Center(child: Text('Tidak ada data kampanye.'));
          }
          if (_selectedCampaign == null) {
            _selectedCampaign = campaigns.first;
          }

          // Ambil data hanya untuk kampanye terpilih
          final donation =
              data.firstWhere((d) => d.nama == _selectedCampaign);
          final barGroup = BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: donation.collected,
                width: 40,
                color: headerColor.withOpacity(0.7),
              ),
            ],
          );

          final maxY = (donation.collected * 1.2).ceilToDouble();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Pilih Kampanye',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  value: _selectedCampaign,
                  items: campaigns
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCampaign = v),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: [barGroup],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  donation.nama,
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == maxY) {
                                return Text(
                                  NumberFormat.compactCurrency(
                                          locale: 'id_ID', name: 'Rp')
                                      .format(value),
                                  style: TextStyle(fontSize: 12),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _InfoCard(
                  label: 'Donasi Terkumpul (Rp)',
                  value: NumberFormat.simpleCurrency(
                          locale: 'id_ID', name: 'Rp', decimalDigits: 0)
                      .format(donation.collected),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: headerColor),
                    onPressed: _openReport,
                    child: Text('DOWNLOAD Laporan',
                        style: TextStyle(color: Colors.white)),
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
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
