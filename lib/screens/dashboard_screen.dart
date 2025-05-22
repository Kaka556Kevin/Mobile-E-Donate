// // lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Donation>> _futureDonations;

  @override
  void initState() {
    super.initState();
    _futureDonations = ApiService().fetchAllDonations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final all = snapshot.data!;
          all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final recent = all.take(5).toList();

          final totalCampaigns = all.length;
          final totalCollected = all.fold<double>(0, (sum, d) => sum + d.collected);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        'Campaigns',
                        totalCampaigns.toString(),
                      ),
                    ),
                    Expanded(
                      child: _infoCard(
                        'Collected',
                        NumberFormat.compactCurrency(
                          locale: 'id_ID',
                          name: 'Rp',
                        ).format(totalCollected),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: PaginatedDataTable(
                    header: Text('Donasi Terkini'),
                    columns: [
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Terkumpul'), numeric: true),
                    ],
                    source: _RecentDataSource(recent),
                    rowsPerPage: recent.length,
                  ),
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
      margin: EdgeInsets.all(4),
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
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _RecentDataSource extends DataTableSource {
  final List<Donation> data;
  _RecentDataSource(this.data);

  @override
  DataRow getRow(int index) {
    final d = data[index];
    return DataRow(
      cells: [
        DataCell(Text(DateFormat('MMM dd yyyy').format(d.createdAt))),
        DataCell(Text(d.nama)),
        DataCell(Text(
          NumberFormat.simpleCurrency(
            locale: 'id_ID',
            name: 'Rp',
          ).format(d.collected),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
