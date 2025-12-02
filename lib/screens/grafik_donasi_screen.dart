// lib/screens/grafik_donasi_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class GrafikDonasiScreen extends StatefulWidget {
  const GrafikDonasiScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4D5BFF);
    const secondaryColor = Color(0xFFE0E0E0); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Analisis Donasi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data.', style: GoogleFonts.poppins()));
          }
          
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text('Belum ada data donasi'));

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0), // Padding bawah 0 agar chart mentok
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Teks
                Text('Target vs Realisasi', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text('Perbandingan performa kampanye', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                
                // Legenda
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(primaryColor, 'Terkumpul'),
                    const SizedBox(width: 24),
                    _buildLegendItem(secondaryColor, 'Target'),
                  ],
                ),
                const SizedBox(height: 24),

                // [MODIFIKASI] Menggunakan Expanded agar Chart mengisi sisa ruang ke bawah
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        // Lebar dinamis: diperlebar agar grafik tidak gepeng
                        width: (data.length * 100.0) < MediaQuery.of(context).size.width 
                            ? MediaQuery.of(context).size.width - 40 
                            : data.length * 100.0, 
                        padding: const EdgeInsets.only(right: 20),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _calculateMaxY(data),
                            // [MODIFIKASI] Menghilangkan grid vertikal agar lebih bersih
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey[200], strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= data.length) return const SizedBox();
                                    final name = data[value.toInt()].nama;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        name.length > 8 ? '${name.substring(0, 8)}...' : name,
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500), // Font diperbesar dikit
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                  reservedSize: 60, // Ruang label bawah diperbesar
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50, // Ruang label kiri diperbesar
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const SizedBox();
                                    return Text(
                                      NumberFormat.compact(locale: 'en_US').format(value),
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                // tooltipBgColor: Colors.blueGrey, // Uncomment jika versi lama
                                tooltipMargin: 8,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final campaign = data[group.x];
                                  final isCollected = rodIndex == 0;
                                  return BarTooltipItem(
                                    '${campaign.nama}\n',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: isCollected ? 'Terkumpul: ' : 'Target: ',
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      TextSpan(
                                        text: NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp').format(rod.toY),
                                        style: TextStyle(color: isCollected ? Colors.greenAccent : Colors.yellowAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            // Data Batang
                            barGroups: data.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barsSpace: 8, // [MODIFIKASI] Jarak antar batang dalam grup
                                barRods: [
                                  // Batang 1: Terkumpul
                                  BarChartRodData(
                                    toY: item.collected,
                                    width: 20, // [MODIFIKASI] Batang diperbesar
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4D5BFF), Color(0xFF8C9EFF)],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  // Batang 2: Target
                                  BarChartRodData(
                                    toY: item.target,
                                    color: secondaryColor,
                                    width: 20, // [MODIFIKASI] Batang diperbesar
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // [MODIFIKASI] Tombol dihapus dari sini
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  double _calculateMaxY(List<Donation> data) {
    if (data.isEmpty) return 100;
    double maxVal = 0;
    for (var d in data) {
      if (d.target > maxVal) maxVal = d.target;
      if (d.collected > maxVal) maxVal = d.collected;
    }
    return maxVal * 1.2;
  }
}