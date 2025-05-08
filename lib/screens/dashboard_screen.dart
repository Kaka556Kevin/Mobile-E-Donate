// import 'package:flutter/material.dart';

// class DashboardScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     const headerColor = Color(0xFF4D5BFF);

//     Widget infoCard(String title, String value) {
//       return Expanded(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           margin: EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: TextStyle(color: Colors.grey[600])),
//               SizedBox(height: 8),
//               Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       );
//     }

//     Widget activityItem(String title, String subtitle, String timeInfo) {
//       return ListTile(
//         contentPadding: EdgeInsets.zero,
//         leading: Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle),
//         ),
//         title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: Text(subtitle),
//         trailing: Text(timeInfo, style: TextStyle(color: Colors.grey)),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Container(
//           color: headerColor,
//           padding: EdgeInsets.only(top: 48, bottom: 24, left: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('E‑DONATE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
//               SizedBox(height: 4),
//               Text('Dashboard', style: TextStyle(color: Colors.white70)),
//             ],
//           ),
//         ),
//         SizedBox(height: 16),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               infoCard('Total galangan', '12'),
//               infoCard('Total terkumpul', 'Rp 24.5M'),
//             ],
//           ),
//         ),
//         SizedBox(height: 16),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Container(
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Text('Informasi Terkini', style: TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//                 Divider(height: 1),
//                 activityItem('Donasi baru', 'Rp 250,000', '2 hours ago'),
//                 activityItem('Penggalangan terbaru', 'Bantuan Banjir', '5 hours ago'),
//                 activityItem('Donasi yang baru dibuat', 'Beasiswa Pendidikan', 'yesterday'),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// lib/screens/dashboard_screen.dart
// import 'package:flutter/material.dart';
// import '../models/form_donasi.dart';
// import '../services/api_service.dart';

// class DashboardScreen extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   late Future<List<FormDonasi>> _futureData;

//   @override
//   void initState() {
//     super.initState();
//     futureDonations = ApiService().getAllDonations();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Dashboard')),
//       body: FutureBuilder<List<FormDonasi>>(
//         future: _futureData,
//         builder: (ctx, snap) {
//           if (snap.hasData) {
//             return SingleChildScrollView(
//               child: PaginatedDataTable(
//                 header: Text('Donasi Terkini'),
//                 columns: [
//                   DataColumn(label: Text('Tanggal Donasi'), onSort: (i, asc) {}),
//                   DataColumn(label: Text('Nama'), onSort: (i, asc) {}),
//                   DataColumn(label: Text('Nominal'), numeric: true),
//                   DataColumn(label: Text('Kontak')),
//                 ],
//                 source: _DonasiDataSource(snap.data!),
//                 rowsPerPage: 5,
//               ),
//             );
//           } else if (snap.hasError) {
//             return Center(child: Text('Error: ${snap.error}'));
//           }
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
// }

// class _DonasiDataSource extends DataTableSource {
//   final List<FormDonasi> data;
//   _DonasiDataSource(this.data);

//   @override
//   DataRow getRow(int index) {
//     final d = data[index];
//     return DataRow(cells: [
//       DataCell(Text(d.tanggal.format('MMM dd yyyy'))),
//       DataCell(Text(d.nama)),
//       DataCell(Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(d.nominal))),
//       DataCell(Text(d.kontak)),
//     ]);
//   }

//   @override bool get isRowCountApproximate => false;
//   @override int get rowCount => data.length;
//   @override int get selectedRowCount => 0;
// }

// lib/screens/dashboard_screen.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';                    // ← Tambahkan ini
// import '../models/form_donasi.dart';
// import '../services/api_service.dart';

// class DashboardScreen extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   late Future<List<FormDonasi>> _futureData;        // ← Gunakan _futureData

//   @override
//   void initState() {
//     super.initState();
//     _futureData = ApiService().getAllDonations();   // ← Assign ke _futureData, tidak futureDonations
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Dashboard')),
//       body: FutureBuilder<List<FormDonasi>>(
//         future: _futureData,                         // ← Pastikan ini _futureData
//         builder: (ctx, snap) {
//           if (snap.hasData) {
//             return SingleChildScrollView(
//               child: PaginatedDataTable(
//                 header: Text('Donasi Terkini'),
//                 columns: [
//                   DataColumn(label: Text('Tanggal Donasi')),
//                   DataColumn(label: Text('Nama')),
//                   DataColumn(label: Text('Nominal'), numeric: true),
//                   DataColumn(label: Text('Kontak')),
//                 ],
//                 source: _DonasiDataSource(snap.data!),
//                 rowsPerPage: 5,
//               ),
//             );
//           } else if (snap.hasError) {
//             return Center(child: Text('Error: ${snap.error}'));
//           }
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
// }

// class _DonasiDataSource extends DataTableSource {
//   final List<FormDonasi> data;
//   _DonasiDataSource(this.data);

//   @override
//   DataRow getRow(int index) {
//     final d = data[index];
//     // gunakan DateFormat.format(), bukan .format() langsung di DateTime
//     final formattedDate = DateFormat('MMM dd yyyy').format(d.tanggal);
//     // gunakan NumberFormat untuk rupiah
//     final formattedNominal = NumberFormat.currency(
//       locale: 'id_ID',
//       symbol: 'Rp ',
//       decimalDigits: 0,
//     ).format(d.nominal);

//     return DataRow(cells: [
//       DataCell(Text(formattedDate)),
//       DataCell(Text(d.nama)),
//       DataCell(Text(formattedNominal)),
//       DataCell(Text(d.kontak)),
//     ]);
//   }

//   @override bool get isRowCountApproximate => false;
//   @override int get rowCount => data.length;
//   @override int get selectedRowCount => 0;
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/form_donasi.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<FormDonasi>> _futureData;

  @override
  void initState() {
    super.initState();
    // Panggil fetchFormDonasi() yang mengembalikan Future<List<FormDonasi>>
    _futureData = ApiService().fetchFormDonasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: FutureBuilder<List<FormDonasi>>(
        future: _futureData,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          } else if (!snap.hasData || snap.data!.isEmpty) {
            return Center(child: Text('Tidak ada data donasi.'));
          }

          final data = snap.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: PaginatedDataTable(
              header: Text('Donasi Terkini'),
              columns: [
                DataColumn(label: Text('Tanggal Donasi')),
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Nominal'), numeric: true),
                DataColumn(label: Text('Kontak')),
              ],
              source: _DonasiDataSource(data),
              rowsPerPage: 5,
            ),
          );
        },
      ),
    );
  }
}

class _DonasiDataSource extends DataTableSource {
  final List<FormDonasi> data;
  _DonasiDataSource(this.data);

  @override
  DataRow getRow(int index) {
    final d = data[index];
    // Format tanggal dan rupiah
    final formattedDate = DateFormat('MMM dd yyyy').format(d.tanggal);
    final formattedNominal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(d.nominal);

    return DataRow(cells: [
      DataCell(Text(formattedDate)),
      DataCell(Text(d.nama)),
      DataCell(Text(formattedNominal)),
      DataCell(Text(d.kontak)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
