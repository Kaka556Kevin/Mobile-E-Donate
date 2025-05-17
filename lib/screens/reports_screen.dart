// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedCampaign;
  List<Donation> _allDonations = [];
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
      final list = await ApiService().fetchAllDonations();
      setState(() => _allDonations = list);
    } catch (e) {
      // handle or rethrow
      rethrow;
    }
  }

  void _onCampaignChanged(String? name) {
    setState(() => _selectedCampaign = name);
  }

  List<FlSpot> _generateSpots() {
    if (_selectedCampaign == null) return [];
    final filtered = _allDonations
        .where((d) => d.nama == _selectedCampaign)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return filtered
        .map((d) => FlSpot(
              d.createdAt.millisecondsSinceEpoch.toDouble(),
              d.collected.toDouble(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan', style: TextStyle(color: Colors.white)),
        backgroundColor: headerColor,
      ),
      body: FutureBuilder<void>(
        future: _fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final campaigns = _allDonations.map((d) => d.nama).toSet().toList();
          final spots = _generateSpots();
          final minX = spots.isEmpty ? 0.0 : spots.first.x;
          final maxX = spots.isEmpty ? 0.0 : spots.last.x;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Pilih Kampanye',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  value: _selectedCampaign,
                  items: campaigns.map((name) {
                    return DropdownMenuItem(
                        value: name, child: Text(name));
                  }).toList(),
                  onChanged: _onCampaignChanged,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _selectedCampaign == null
                      ? Center(
                          child:
                              Text('Pilih kampanye untuk melihat grafik'),
                        )
                      : LineChart(
                          LineChartData(
                            minX: minX,
                            maxX: maxX,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                color: headerColor,
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: spots.length > 1
                                      ? (maxX - minX) / (spots.length - 1)
                                      : 1.0,
                                  getTitlesWidget: (value, meta) {
                                    final dt = DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());
                                    return Text(
                                      DateFormat('dd MMM').format(dt),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
