// lib/screens/donation_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';

class DonationDetailScreen extends StatelessWidget {
  final Donation donation;

  const DonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4D5BFF);
    final currencyFmt = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ', decimalDigits: 0);
    final progress = donation.target > 0 ? (donation.collected / donation.target).clamp(0.0, 1.0) : 0.0;
    
    // [MODIFIKASI] Mengambil status donasi
    final bool isClosed = donation.isClosed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // ... (Kode AppBar tetap sama)
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  donation.gambar.isNotEmpty
                      ? Image.network(
                          'https://dalitmayaan.com/storage/${donation.gambar}',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, _) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        )
                      : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50, color: Colors.grey)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                donation.nama,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isClosed ? Colors.red[100] : (progress >= 1.0 ? Colors.green[100] : Colors.blue[100]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isClosed ? 'Ditutup' : (progress >= 1.0 ? 'Tercapai' : 'Aktif'),
                            style: GoogleFonts.poppins(
                              color: isClosed ? Colors.red[800] : (progress >= 1.0 ? Colors.green[800] : Colors.blue[800]),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(donation.createdAt),
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // [MODIFIKASI] Widget Sisa Waktu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isClosed ? Colors.red[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isClosed ? Colors.red[200]! : Colors.orange[200]!)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: isClosed ? Colors.red : Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              donation.sisaWaktuText, // Teks otomatis dari model
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: isClosed ? Colors.red : Colors.orange[800]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progress Section (Tetap sama)
                    Text('Progress Donasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Terkumpul', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                            Text(currencyFmt.format(donation.collected), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Target', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                            Text(currencyFmt.format(donation.target), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Description
                    Text('Tentang Program', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Text(
                      donation.deskripsi,
                      style: GoogleFonts.poppins(color: Colors.black87, height: 1.6),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      // ... (Floating Action Button tetap sama)
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'edit',
            backgroundColor: Colors.orange,
            elevation: 2,
            onPressed: () {
              Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => DonationFormScreen(donation: donation)),
              ).then((refresh) {
                if (refresh == true) Navigator.pop(context, true);
              });
            },
            child: const Icon(Icons.edit_rounded, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'delete',
            backgroundColor: Colors.redAccent,
            elevation: 4,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Hapus Donasi?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  content: Text('Tindakan ini tidak dapat dibatalkan.', style: GoogleFonts.poppins()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true), 
                      child: const Text('Hapus')
                    ),
                  ],
                )
              );
              
              if (confirm == true) {
                await ApiService().deleteDonation(donation.id);
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true);
              }
            },
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}