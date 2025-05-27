// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/donation_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';
import 'donation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Donation>> _futureDonations;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    setState(() {
      _futureDonations = DonationService().fetchDonations();
    });
  }

  String formatCurrency(double amount) => NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp').format(amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CMS Donasi')),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Gagal memuat data: ${snapshot.error}'));  

          final donations = snapshot.data ?? [];
          final totalCollected = donations.fold<double>(0, (sum, d) => sum + d.collected);
          final target = 50000000.0;
          final progress = (totalCollected / target).clamp(0.0, 1.0);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Terkumpul: ${formatCurrency(totalCollected)} / Target: ${formatCurrency(target)}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadDonations(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final d = donations[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          title: Text(d.nama, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Target: ${formatCurrency(d.target)} • Collected: ${formatCurrency(d.collected)}'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => DonationDetailScreen(donation: d)),
                          ).then((refresh) { if (refresh == true) _loadDonations(); }),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => DonationFormScreen()),
        ).then((refresh) { if (refresh == true) _loadDonations(); }),
        child: Icon(Icons.add),
      ),
    );
  }
}
