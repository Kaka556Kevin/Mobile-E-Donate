// lib/screens/funds_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/donation.dart';

class FundsScreen extends StatefulWidget {
  @override
  _FundsScreenState createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  String? _selectedCampaign;
  List<Donation> _allDonations = [];
  Donation? _selectedDonation;
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _loadDonations();
  }

  Future<void> _loadDonations() async {
    final list = await ApiService().fetchAllDonations();
    setState(() {
      _allDonations = list;
    });
  }

  void _onCampaignChanged(String? name) {
    setState(() {
      _selectedCampaign = name;
      _selectedDonation =
          _allDonations.firstWhere((d) => d.nama == name, orElse: () => _allDonations.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uang Donasi'),
      ),
      body: FutureBuilder<void>(
        future: _fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Pilih Kampanye',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  items: _allDonations
                      .map((d) => d.nama)
                      .toSet()
                      .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                      .toList(),
                  value: _selectedCampaign,
                  onChanged: _onCampaignChanged,
                ),
                SizedBox(height: 16),
                if (_selectedDonation != null) ...[
                  _buildInfoCard(
                    'Target',
                    NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ')
                        .format(_selectedDonation!.target),
                  ),
                  SizedBox(height: 8),
                  _buildInfoCard(
                    'Terkumpul',
                    NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ')
                        .format(_selectedDonation!.collected),
                  ),
                  SizedBox(height: 8),
                  _buildInfoCard(
                    'Tersedia',
                    NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ')
                        .format(_selectedDonation!.target - _selectedDonation!.collected),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
