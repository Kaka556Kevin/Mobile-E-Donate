import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../services/api_service.dart';
import 'donation_form_screen.dart';
import 'donation_detail_screen.dart';

class DonationsScreen extends StatefulWidget {
  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  late Future<List<Donation>> _futureDonations;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    setState(() {
      _futureDonations = ApiService().getAllDonations();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final headerColor = Color(0xFF4D5BFF);
    return Column(
      children: [
        // Header + Search + FAB
        Container(
          color: headerColor,
          padding: EdgeInsets.only(top: 48, bottom: 24, left: 16, right: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: headerColor,
                onPressed: () {
                  Navigator.push<bool>(
                    ctx,
                    MaterialPageRoute(builder: (_) => DonationFormScreen()),
                  ).then((refresh) {
                    if (refresh == true) _loadDonations();
                  });
                },
                child: Icon(Icons.add),
              )
            ],
          ),
        ),

        // List
        Expanded(
          child: FutureBuilder<List<Donation>>(
            future: _futureDonations,
            builder: (c, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (s.hasError) {
                return Center(child: Text('Error: ${s.error}'));
              }
              final list = (s.data ?? [])
                  .where((d) => d.nama.toLowerCase().contains(_searchCtrl.text.toLowerCase()))
                  .toList();
              if (list.isEmpty) return Center(child: Text('Tidak ada kampanye.'));
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final d = list[i];
                  final collectedText = NumberFormat.compactCurrency(
                          locale: 'id_ID', symbol: 'Rp ')
                      .format(d.collected);
                  final targetText = NumberFormat.compactCurrency(
                          locale: 'id_ID', symbol: 'Rp ')
                      .format(d.target);
                  final isDone = d.collected >= d.target;
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      tileColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(d.nama, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target: $targetText'),
                          Text('Collected: $collectedText'),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDone ? Colors.green[100] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isDone ? 'Selesai' : 'Aktif',
                          style: TextStyle(
                            color: isDone ? Colors.green : Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push<bool>(
                          c,
                          MaterialPageRoute(builder: (_) => DonationDetailScreen(donation: d)),
                        ).then((refresh) {
                          if (refresh == true) _loadDonations();
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
