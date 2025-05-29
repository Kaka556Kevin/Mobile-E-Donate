// // lib/screens/funds_screen.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/api_service.dart';
// import '../models/donation.dart';

// class FundsScreen extends StatefulWidget {
//   @override
//   _FundsScreenState createState() => _FundsScreenState();
// }

// class _FundsScreenState extends State<FundsScreen> {
//   String? _selectedCampaign;
//   List<Donation> _allDonations = [];
//   Donation? _selectedDonation;
//   late Future<void> _fetchFuture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchFuture = _loadDonations();
//   }

//   Future<void> _loadDonations() async {
//     final list = await ApiService().fetchAllDonations();
//     setState(() {
//       _allDonations = list;
//     });
//   }

//   void _onCampaignChanged(String? name) {
//     setState(() {
//       _selectedCampaign = name;
//       _selectedDonation =
//           _allDonations.firstWhere((d) => d.nama == name, orElse: () => _allDonations.first);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Uang Donasi'),
//       ),
//       body: FutureBuilder<void>(
//         future: _fetchFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           return Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     hintText: 'Pilih Kampanye',
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   ),
//                   items: _allDonations
//                       .map((d) => d.nama)
//                       .toSet()
//                       .map((name) => DropdownMenuItem(value: name, child: Text(name)))
//                       .toList(),
//                   value: _selectedCampaign,
//                   onChanged: _onCampaignChanged,
//                 ),
//                 SizedBox(height: 16),
//                 if (_selectedDonation != null) ...[
//                   _buildInfoCard(
//                     'Target',
//                     NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ')
//                         .format(_selectedDonation!.target),
//                   ),
//                   SizedBox(height: 8),
//                   _buildInfoCard(
//                     'Terkumpul',
//                     NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ')
//                         .format(_selectedDonation!.collected),
//                   ),
//                   SizedBox(height: 8),
//                   _buildInfoCard(
//                     'Tersedia',
//                     NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ')
//                         .format(_selectedDonation!.target - _selectedDonation!.collected),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoCard(String title, String value) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: TextStyle(color: Colors.grey[600])),
//           SizedBox(height: 8),
//           Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/funds_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import '../models/uang_donasi.dart';

class FundsScreen extends StatefulWidget {
  @override
  _FundsScreenState createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  String? _selectedCampaign;
  List<Donation> _campaigns = [];
  List<UangDonasi> _records = [];
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initData();
  }

  Future<void> _initData() async {
    // Load campaigns and initial records
    _campaigns = await ApiService().fetchAllDonations();
    if (_campaigns.isNotEmpty) {
      _selectedCampaign = _campaigns.first.nama;
      await _loadRecords(_selectedCampaign!);
    }
    setState(() {});
  }

  Future<void> _loadRecords(String campaignName) async {
    final all = await ApiService().fetchAllUangDonasi();
    // Filter records by campaign name
    _records = all.where((r) => r.namaDonasi == campaignName).toList();
    setState(() {});
  }

  void _onCampaignChanged(String? newName) async {
    if (newName == null) return;
    setState(() => _selectedCampaign = newName);
    await _loadRecords(newName);
  }

  void _onNewCatatan() async {
    // Navigate to a create screen (already implemented) or show form
    await Navigator.pushNamed(context, '/uang-donasi/create', arguments: _selectedCampaign);
    if (_selectedCampaign != null) {
      await _loadRecords(_selectedCampaign!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Uang Donasi')),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown campaign
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Pilih Kampanye',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _campaigns.map((d) => d.nama).toSet().map(
                    (name) => DropdownMenuItem(value: name, child: Text(name)),
                  ).toList(),
                  value: _selectedCampaign,
                  onChanged: _onCampaignChanged,
                ),
                SizedBox(height: 16),
                if (_selectedCampaign != null) ...[
                  // Info cards
                  _buildCard('Target', _formatCurrency(_campaigns.firstWhere((d) => d.nama == _selectedCampaign!).target)),
                  SizedBox(height: 8),
                  _buildCard('Terkumpul', _formatCurrency(_campaigns.firstWhere((d) => d.nama == _selectedCampaign!).collected)),
                  SizedBox(height: 8),
                  _buildCard('Tersedia', _formatCurrency(
                    _campaigns.firstWhere((d) => d.nama == _selectedCampaign!).target -
                    _campaigns.firstWhere((d) => d.nama == _selectedCampaign!).collected,
                  )),
                  SizedBox(height: 16),
                  // New Catatan button
                  ElevatedButton.icon(
                    onPressed: _onNewCatatan,
                    icon: Icon(Icons.add),
                    label: Text('New Catatan'),
                  ),
                  SizedBox(height: 16),
                  // List catatan
                  Expanded(
                    child: _records.isEmpty
                        ? Center(child: Text('Belum ada catatan'))
                        : ListView.separated(
                            itemCount: _records.length,
                            separatorBuilder: (_, __) => Divider(),
                            itemBuilder: (_, i) {
                              final r = _records[i];
                              return ListTile(
                                title: Text(r.namaDonasi),
                                subtitle: Text(_formatCurrency(r.uangMasuk) + ' in/out: ' + _formatCurrency(r.uangKeluar)),
                                trailing: Text('Saldo: ' + _formatCurrency(r.saldo)),
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String label, String value) {
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
          Text(label, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }
}