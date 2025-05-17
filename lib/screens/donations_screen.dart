// lib/screens/donations_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';
import 'donation_detail_screen.dart';

class DonationsScreen extends StatefulWidget {
  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  late Future<List<Donation>> _futureDonations;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    setState(() {
      _futureDonations = ApiService().fetchAllDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color(0xFF4D5BFF),
          padding: EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelola Donasi',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mengelola Donasi yang ada',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 12),
              FloatingActionButton(
                backgroundColor: Color(0xFF4D5BFF),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DonationFormScreen(),
                  ),
                ).then((refresh) {
                  if (refresh == true) _loadDonations();
                }),
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Donation>>(
            future: _futureDonations,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final list = snapshot.data!
                  .where((d) => d.nama.toLowerCase().contains(
                        _searchCtrl.text.toLowerCase(),
                      ))
                  .toList();
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final d = list[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(
                        d.nama,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target: Rp \${d.target.toInt()}'),
                          Text('Collected: Rp \${d.collected.toInt()}'),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: d.collected >= d.target
                              ? Colors.green[100]
                              : Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          d.collected >= d.target ? 'Selesai' : 'Aktif',
                          style: TextStyle(
                            color: d.collected >= d.target
                                ? Colors.green
                                : Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DonationDetailScreen(donation: d),
                        ),
                      ).then((value) {
                        if (value == true) _loadDonations();
                      }),
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
