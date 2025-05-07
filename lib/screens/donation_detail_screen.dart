import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';

class DonationDetailScreen extends StatelessWidget {
  final Donation donation;

  DonationDetailScreen({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(donation.nama)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network("http://10.0.2.2:8000/storage/${donation.gambar}"),
            SizedBox(height: 20),
            Text('Deskripsi: ${donation.deskripsi}'),
            Text('Target Terkumpul: ${donation.targetTerkumpul}'),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DonationFormScreen(donation: donation),
                ),
              );
            },
            child: Icon(Icons.edit),
          ),
          FloatingActionButton(
            onPressed: () async {
              await ApiService().deleteDonation(donation.id);
              Navigator.pop(context);
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
