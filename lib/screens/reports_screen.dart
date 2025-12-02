// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4D5BFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Laporan Donasi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data tersedia.', style: GoogleFonts.poppins()));
          }

          final data = snapshot.data!;
          final campaigns = data.map((d) => d.nama).toSet().toList();
          _selectedCampaign ??= campaigns.first;

          final donation = data.firstWhere((d) => d.nama == _selectedCampaign);
          final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

          // Data Chart Group (0: Terkumpul, 1: Target)
          final barGroups = [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: donation.collected,
                  color: Colors.green,
                  width: 30, // Batang diperbesar
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: (donation.target * 1.2), color: Colors.grey[100])
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: donation.target,
                  color: primaryColor,
                  width: 30, // Batang diperbesar
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: (donation.target * 1.2), color: Colors.grey[100])
                ),
              ],
            ),
          ];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Dropdown Selection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCampaign,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
                      items: campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins()))).toList(),
                      onChanged: (v) => setState(() => _selectedCampaign = v),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Info Cards (Moved up for better layout)
                Row(
                  children: [
                    Expanded(child: _InfoCard(label: 'Terkumpul', value: fmt.format(donation.collected), color: Colors.green, icon: Icons.download_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _InfoCard(label: 'Target', value: fmt.format(donation.target), color: primaryColor, icon: Icons.flag_rounded)),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Chart (Expanded to fill space)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                    ),
                    child: Column(
                      children: [
                        Text('Analisis Performa', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 4),
                        // Legenda
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _legend(Colors.green, "Terkumpul"),
                            const SizedBox(width: 16),
                            _legend(primaryColor, "Target"),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Grafik
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              barGroups: barGroups,
                              maxY: (donation.target * 1.2), // Sedikit buffer di atas target
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final titles = ['Realisasi', 'Target'];
                                      if (val.toInt() >= titles.length) return const SizedBox();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(titles[val.toInt()], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Bersih tanpa angka kiri
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey[100], strokeWidth: 1),
                              ),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipMargin: 8,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      NumberFormat.compact(locale: 'id').format(rod.toY),
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ruang kosong di bawah agar tidak terlalu mepet
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _InfoCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}