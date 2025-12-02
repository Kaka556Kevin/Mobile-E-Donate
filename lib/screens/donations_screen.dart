// lib/screens/donations_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';
import 'donation_detail_screen.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  late Future<List<Donation>> _futureDonations;
  final TextEditingController _searchCtrl = TextEditingController();
  String _sortBy = 'Terbaru';

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _futureDonations = ApiService().fetchAllDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4D5BFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 24, left: 24, right: 24),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kelola Donasi', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Pantau kampanye aktif', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DonationFormScreen()),
                      ).then((refresh) { if (refresh == true) _loadDonations(); }),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.add, color: primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: GoogleFonts.poppins(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Cari kampanye...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.sort_rounded, color: primaryColor),
                      ),
                      onSelected: (val) => setState(() => _sortBy = val),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Terbaru', child: Text('📅 Terbaru')),
                        const PopupMenuItem(value: 'Terlama', child: Text('📅 Terlama')),
                        const PopupMenuItem(value: 'Target', child: Text('🎯 Target Tertinggi')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDonations,
              color: primaryColor,
              child: FutureBuilder<List<Donation>>(
                future: _futureDonations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins()));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('Belum ada data.', style: GoogleFonts.poppins()));

                  List<Donation> list = snapshot.data!
                      .where((d) => d.nama.toLowerCase().contains(_searchCtrl.text.toLowerCase()))
                      .toList();

                  if (_sortBy == 'Terbaru') list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  else if (_sortBy == 'Terlama') list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  else if (_sortBy == 'Target') list.sort((a, b) => b.target.compareTo(a.target));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final d = list[index];
                      final currency = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(d.collected);
                      final progress = d.target == 0 ? 0.0 : (d.collected / d.target).clamp(0.0, 1.0);
                      
                      // [FIX WAKTU]: Logika tampilan status waktu
                      String timeText;
                      Color timeColor;
                      
                      if (d.isClosed) {
                        timeText = "Donasi Ditutup";
                        timeColor = Colors.red;
                      } else if (d.sisaHari == 0) {
                        timeText = "Hari ini terakhir";
                        timeColor = Colors.orange[800]!;
                      } else {
                        timeText = "${d.sisaHari} Hari Tersisa";
                        timeColor = Colors.grey[600]!;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DonationDetailScreen(donation: d)),
                            ).then((val) { if (val == true) _loadDonations(); }),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 60, height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                          image: d.gambar.isNotEmpty 
                                            ? DecorationImage(image: NetworkImage('https://dalitmayaan.com/storage/${d.gambar}'), fit: BoxFit.cover) 
                                            : null,
                                        ),
                                        child: d.gambar.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(d.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time_rounded, size: 14, color: timeColor),
                                                const SizedBox(width: 4),
                                                // [FIX]: Menampilkan teks yang sudah diperbaiki
                                                Text(timeText, style: GoogleFonts.poppins(fontSize: 12, color: timeColor, fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: d.isClosed ? Colors.red[50] : (d.collected >= d.target ? Colors.green[50] : Colors.blue[50]),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          d.isClosed ? 'Selesai' : (d.collected >= d.target ? 'Tercapai' : 'Aktif'),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10, fontWeight: FontWeight.bold,
                                            color: d.isClosed ? Colors.red : (d.collected >= d.target ? Colors.green : primaryColor)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[100], color: primaryColor, minHeight: 6),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Terkumpul: $currency', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                                      Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}