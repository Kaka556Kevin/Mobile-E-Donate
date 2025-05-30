// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../models/form_donasi.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Donation>> _futureCampaigns;
  late Future<List<FormDonasi>> _futureDonors;
  final _donorSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureCampaigns = ApiService().fetchAllDonations();
    _futureDonors   = ApiService().fetchFormDonasi();
  }

  @override
  void dispose() {
    _donorSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: FutureBuilder<List<Donation>>(
        future: _futureCampaigns,
        builder: (ctx, snapCampaigns) {
          if (snapCampaigns.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapCampaigns.hasError)
            return Center(child: Text('Error: ${snapCampaigns.error}'));

          final campaigns = snapCampaigns.data!..sort((a,b)=>b.createdAt.compareTo(a.createdAt));
          final recent    = campaigns.take(5).toList();
          final totalCamp = campaigns.length;
          final totalColl = campaigns.fold<double>(0, (sum,d)=> sum + d.collected);

          return Column(
            children: [
              // — Info cards
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(child: _infoCard('Campaigns', totalCamp.toString())),
                    Expanded(child: _infoCard('Collected', currency.format(totalColl))),
                  ],
                ),
              ),

              // — Donasi Terkini
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PaginatedDataTable(
                    dataRowHeight: totalColl > 0 ? 48 : 32,
                    header: Text('Donasi Terkini'),
                    columns: [
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Terkumpul'), numeric: true),
                    ],
                    source: _RecentCampaignSource(recent),
                    rowsPerPage: recent.length,
                  ),
                ),
              ),

              Divider(),

              // — Donatur Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _donorSearchCtrl,
                  decoration: InputDecoration(
                    labelText: 'Cari Donatur...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(height: 8),

              // — Daftar Donatur
              Flexible(
                child: FutureBuilder<List<FormDonasi>>(
                  future: _futureDonors,
                  builder: (ctx, snapDonors) {
                    if (snapDonors.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    if (snapDonors.hasError)
                      return Center(child: Text('Error: ${snapDonors.error}'));

                    // filter by search
                    final allDonors = snapDonors.data!
                      .where((d) => d.nama.toLowerCase().contains(
                          _donorSearchCtrl.text.toLowerCase()))
                      .toList();

                    if (allDonors.isEmpty) {
                      return Center(child: Text('Belum ada donatur.'));
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PaginatedDataTable(
                        dataRowHeight: 48,
                        header: Text('Daftar Donatur'),
                        columns: [
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Nominal'), numeric: true),
                        ],
                        source: _DonorDataSource(allDonors),
                        rowsPerPage: allDonors.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8),
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

// DataTableSource for “Donasi Terkini”
class _RecentCampaignSource extends DataTableSource {
  final List<Donation> data;
  final DateFormat _fmt = DateFormat('dd MMM yyyy', 'id_ID');
  final NumberFormat _cur = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp', decimalDigits: 0);

  _RecentCampaignSource(this.data);

  @override
  DataRow getRow(int index) {
    final d = data[index];
    return DataRow(cells: [
      DataCell(Text(_fmt.format(d.createdAt))),
      DataCell(Text(d.nama)),
      DataCell(Text(_cur.format(d.collected))),
    ]);
  }

  @override bool get isRowCountApproximate => false;
  @override int get rowCount => data.length;
  @override int get selectedRowCount => 0;
}

// DataTableSource for “Daftar Donatur”
class _DonorDataSource extends DataTableSource {
  final List<FormDonasi> data;
  final DateFormat _fmt = DateFormat('dd MMM yyyy', 'id_ID');
  final NumberFormat _cur = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp', decimalDigits: 0);

  _DonorDataSource(this.data);

  @override
  DataRow getRow(int index) {
    final d = data[index];
    return DataRow(cells: [
      DataCell(Text(_fmt.format(d.tanggal))),
      DataCell(Text(d.nama)),
      DataCell(Text(_cur.format(d.nominal))),
    ]);
  }

  @override bool get isRowCountApproximate => false;
  @override int get rowCount => data.length;
  @override int get selectedRowCount => 0;
}
