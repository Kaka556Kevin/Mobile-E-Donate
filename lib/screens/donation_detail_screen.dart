import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'package:intl/intl.dart';
import 'donation_form_screen.dart';

class DonationDetailScreen extends StatelessWidget {
  final Donation donation;

  DonationDetailScreen({required this.donation});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text(donation.nama)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://dalitmayaan.com/storage/${donation.gambar}',
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(donation.deskripsi),
          SizedBox(height: 12),
          Text('Target Terkumpul: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(donation.target)}'),
          Text('Terkumpul: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(donation.collected)}'),
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
                ctx,
                MaterialPageRoute(builder: (_) => DonationFormScreen(donation: donation)),
              ).then((refresh) {
                if (refresh == true) Navigator.pop(ctx, true);
              });
            },
            child: Icon(Icons.edit),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'del',
            backgroundColor: Colors.red,
            onPressed: () async {
              await ApiService().deleteDonation(donation.id);
              Navigator.pop(ctx, true);
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
