// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/donation.dart';
import '../models/form_donasi.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Donation>> _futureCampaigns;
  late Future<List<FormDonasi>> _futureDonors;
  final _donorSearchCtrl = TextEditingController();
  
  // [MODIFIKASI] State untuk filter sort donatur
  String _sortDonorBy = 'Terbaru'; 

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _futureCampaigns = ApiService().fetchAllDonations();
    _futureDonors = ApiService().fetchFormDonasi();
  }

  @override
  void dispose() {
    _donorSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp ',
      decimalDigits: 0,
    );
    const primaryColor = Color(0xFF4D5BFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: () => setState(() => _loadAllData()),
          ),
        ],
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureCampaigns,
        builder: (ctx, snapCampaigns) {
          if (snapCampaigns.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapCampaigns.hasError) {
            return Center(child: Text('Error: ${snapCampaigns.error}', style: GoogleFonts.poppins()));
          }

          final campaigns = snapCampaigns.data!
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final recent = campaigns.take(5).toList();
          final totalCamp = campaigns.length;
          final totalColl = campaigns.fold<double>(
            0,
            (sum, d) => sum + d.collected,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // — Info cards row
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        title: 'Kampanye',
                        value: totalCamp.toString(),
                        icon: Icons.campaign_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _infoCard(
                        title: 'Terkumpul',
                        value: NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(totalColl),
                        icon: Icons.monetization_on_rounded,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // — Donasi Terkini
                Text('Kampanye Terbaru', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final d = recent[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.volunteer_activism, color: primaryColor),
                        ),
                        title: Text(d.nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(DateFormat('dd MMM yyyy').format(d.createdAt), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        trailing: Text(
                          currency.format(d.collected),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // — Donatur Section
                Text('Daftar Donatur', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // [MODIFIKASI] Row Search & Sort Filter
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _donorSearchCtrl,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          hintText: 'Cari nama donatur...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Dropdown Sort UI
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Icon(Icons.sort_rounded, color: primaryColor),
                      ),
                      onSelected: (val) => setState(() => _sortDonorBy = val),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Terbaru', child: Text('📅 Terbaru')),
                        const PopupMenuItem(value: 'Terlama', child: Text('📅 Terlama')),
                        const PopupMenuItem(value: 'Tertinggi', child: Text('💰 Nominal Tertinggi')),
                        const PopupMenuItem(value: 'Terendah', child: Text('💰 Nominal Terendah')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // List Donatur
                FutureBuilder<List<FormDonasi>>(
                  future: _futureDonors,
                  builder: (ctx, snapDonors) {
                    if (snapDonors.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                    }
                    if (snapDonors.hasError) {
                      return Text('Gagal memuat donatur.', style: GoogleFonts.poppins(color: Colors.red));
                    }

                    // 1. Filter
                    final allDonors = snapDonors.data!
                        .where((d) => d.nama
                            .toLowerCase()
                            .contains(_donorSearchCtrl.text.toLowerCase()))
                        .toList();

                    // 2. Sort Logic [MODIFIKASI]
                    if (_sortDonorBy == 'Terbaru') {
                      allDonors.sort((a, b) => b.tanggal.compareTo(a.tanggal));
                    } else if (_sortDonorBy == 'Terlama') {
                      allDonors.sort((a, b) => a.tanggal.compareTo(b.tanggal));
                    } else if (_sortDonorBy == 'Tertinggi') {
                      allDonors.sort((a, b) => b.nominal.compareTo(a.nominal));
                    } else if (_sortDonorBy == 'Terendah') {
                      allDonors.sort((a, b) => a.nominal.compareTo(b.nominal));
                    }

                    if (allDonors.isEmpty) {
                      return Center(child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Tidak ada data donatur.', style: GoogleFonts.poppins(color: Colors.grey)),
                      ));
                    }

                    // Tampilkan maksimal 10 donatur
                    final displayDonors = allDonors.take(10).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayDonors.length,
                      itemBuilder: (context, index) {
                        final d = displayDonors[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              child: Text(d.nama.isNotEmpty ? d.nama[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black54)),
                            ),
                            title: Text(d.nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
                            subtitle: Text(DateFormat('dd MMM yyyy').format(d.tanggal), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                            trailing: Text(
                              currency.format(d.nominal),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}