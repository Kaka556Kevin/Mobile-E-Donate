// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Untuk format tanggal dan mata uang
// import '../models/donation.dart'; // Sesuaikan path jika berbeda

// class DonationListItem extends StatelessWidget {
//   final Donatur donatur;

//   const DonationListItem({super.key, required this.donatur});

//   @override
//   Widget build(BuildContext context) {
//     // Format tanggal (contoh: "24 Mei 2025")
//     final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(donatur.tanggal ?? DateTime.now());

//     // Format mata uang Indonesia (contoh: "Rp5.000.000")
//     final formattedAmount = NumberFormat.simpleCurrency(
//       locale: 'id_ID',
//       name: 'Rp',
//       decimalDigits: 0,
//     ).format(donatur.nominal);

//     return ListTile(
//       title: Text(donatur.nama),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Nominal: $formattedAmount'),
//           Text('Tanggal: $formattedDate'),
//         ],
//       ),
//       leading: Icon(Icons.person, color: Colors.grey), // Ikon opsional
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(color: Colors.grey[200]!),
//       ),
//     );
//   }
// }

// lib/widgets/donation_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';

class DonationListItem extends StatelessWidget {
  final Donatur donatur;

  const DonationListItem({super.key, required this.donatur});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(donatur.tanggal ?? DateTime.now());
    final formattedAmount = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      name: 'Rp',
      decimalDigits: 0,
    ).format(donatur.nominal);

    return ListTile(
      title: Text(donatur.nama),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nominal: $formattedAmount'),
          Text('Tanggal: $formattedDate'),
        ],
      ),
      leading: Icon(Icons.person, color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
    );
  }
}
