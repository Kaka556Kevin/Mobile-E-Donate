// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../models/form_donasi.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
    _loadAllData();
  }

  void _loadAllData() {
    _futureCampaigns = ApiService().fetchAllDonations();
    _futureDonors = ApiService().fetchFormDonasi();
  }

  @override
  void dispose() {
    _donorSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _loadAllData();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureCampaigns,
        builder: (ctx, snapCampaigns) {
          if (snapCampaigns.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapCampaigns.hasError) {
            return Center(child: Text('Error: ${snapCampaigns.error}'));
          }

          final campaigns = snapCampaigns.data!
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final recent = campaigns.take(5).toList();
          final totalCamp = campaigns.length;
          final totalColl = campaigns.fold<double>(
            0,
            (sum, d) => sum + d.collected,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // — Info cards row
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        title: 'Campaigns',
                        value: totalCamp.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoCard(
                        title: 'Collected',
                        value: currency.format(totalColl),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // — Donasi Terkini
                const Text(
                  'Donasi Terkini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: _RecentCampaignTable(recent: recent, currency: currency),
                  ),
                ),
                const SizedBox(height: 24),

                // — Donatur Search Field
                TextField(
                  controller: _donorSearchCtrl,
                  decoration: InputDecoration(
                    labelText: 'Cari Donatur...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),

                // — Daftar Donatur
                FutureBuilder<List<FormDonasi>>(
                  future: _futureDonors,
                  builder: (ctx, snapDonors) {
                    if (snapDonors.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapDonors.hasError) {
                      return Center(child: Text('Error: ${snapDonors.error}'));
                    }

                    final allDonors = snapDonors.data!
                        .where((d) => d.nama
                            .toLowerCase()
                            .contains(_donorSearchCtrl.text.toLowerCase()))
                        .toList();

                    if (allDonors.isEmpty) {
                      return const Center(child: Text('Belum ada donatur.'));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Daftar Donatur',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            child: _DonorListTable(
                              donors: allDonors,
                              currency: currency,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard({required String title, required String value}) {
    return Container(
      height: 72, // slightly smaller to remove 1px overflow
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// “Donasi Terkini” using a Table to fill available width
class _RecentCampaignTable extends StatelessWidget {
  final List<Donation> recent;
  final NumberFormat currency;
  final DateFormat _fmt = DateFormat('dd MMM yyyy', 'id_ID');

  _RecentCampaignTable({
    Key? key,
    required this.recent,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Using 3 columns: Date, Name, Collected
      return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          // You can adjust flex values as needed
          0: FlexColumnWidth(2), // Tanggal
          1: FlexColumnWidth(3), // Nama
          2: FlexColumnWidth(2), // Terkumpul
        },
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tanggal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Terkumpul',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          // Data rows
          for (var d in recent)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    _fmt.format(d.createdAt),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    d.nama,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    currency.format(d.collected),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }
}

/// “Daftar Donatur” using a Table to fill available width
class _DonorListTable extends StatelessWidget {
  final List<FormDonasi> donors;
  final NumberFormat currency;
  final DateFormat _fmt = DateFormat('dd MMM yyyy', 'id_ID');

  _DonorListTable({
    Key? key,
    required this.donors,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Using 3 columns: Date, Name, Nominal
      return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          // Flex ratios may be adjusted for readability
          0: FlexColumnWidth(2), // Tanggal
          1: FlexColumnWidth(3), // Nama
          2: FlexColumnWidth(2), // Nominal
        },
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tanggal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nominal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          // Data rows
          for (var d in donors)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    _fmt.format(d.tanggal),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    d.nama,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    currency.format(d.nominal),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }
}
