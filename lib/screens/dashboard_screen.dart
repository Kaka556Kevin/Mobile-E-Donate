import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Donation>> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureData = ApiService().getAllDonations();
    });
  }

  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: headerColor,
            padding: EdgeInsets.only(top: 48, bottom: 24, left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('E-DONATE',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Dashboard', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Info Cards
          FutureBuilder<List<Donation>>(
            future: _futureData,
            builder: (c, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (s.hasError) {
                return Center(child: Text('Error: ${s.error}'));
              } else if (!s.hasData || s.data!.isEmpty) {
                return Center(child: Text('Belum ada donasi.'));
              }
              final list = s.data!;
              final totalCampaigns = list.length.toString();
              final totalCollected = NumberFormat.compactCurrency(
                      locale: 'id_ID', symbol: 'Rp ')
                  .format(list.fold<double>(0, (sum, d) => sum + d.collected));
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildInfoCard('Total Kampanye', totalCampaigns),
                    _buildInfoCard('Total Terkumpul', totalCollected),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
