// lib/screens/donation_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';

class DonationDetailScreen extends StatelessWidget {
  final Donation donation;

  DonationDetailScreen({required this.donation});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus donasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ApiService().deleteDonation(donation.id);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(donation.nama)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://dalitmayaan.com/storage/${donation.gambar}',
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(donation.deskripsi),
          const SizedBox(height: 12),
          Text(
            'Target Terkumpul: ${NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ').format(donation.target)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'edit',
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => DonationFormScreen(donation: donation),
                ),
              ).then((refresh) {
                if (refresh == true) Navigator.pop(context, true);
              });
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'delete',
            backgroundColor: Colors.red,
            onPressed: () => _confirmAndDelete(context),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
