// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../models/donation.dart';
// import 'donation_form_screen.dart';
// import 'donation_detail_screen.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late Future<List<Donation>> futureDonations;

//   @override
//   void initState() {
//     super.initState();
//     futureDonations = ApiService().getAllDonations();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('CMS Donasi')),
//       body: FutureBuilder<List<Donation>>(
//         future: futureDonations,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 Donation donation = snapshot.data![index];
//                 return ListTile(
//                   title: Text(donation.nama),
//                   subtitle: Text('${donation.targetTerkumpul}'),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             DonationDetailScreen(donation: donation),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Text("${snapshot.error}");
//           }
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DonationFormScreen(),
//             ),
//           ).then((_) {
//             setState(() {
//               futureDonations = ApiService().getAllDonations();
//             });
//           });
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';
import 'donation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Donation>> _futureDonations;

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
  Widget build(BuildContext context) {
    final headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      appBar: AppBar(
        title: Text('CMS Donasi'),
        backgroundColor: headerColor,
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final list = snap.data;
          if (list == null || list.isEmpty) {
            return Center(child: Text('Belum ada donasi.'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final d = list[i];
              final targetText = NumberFormat.compactCurrency(
                      locale: 'id_ID', symbol: 'Rp ')
                  .format(d.target);
              final collectedText = NumberFormat.compactCurrency(
                      locale: 'id_ID', symbol: 'Rp ')
                  .format(d.collected);
              final isDone = d.collected >= d.target;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(d.nama, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target: $targetText'),
                      Text('Terkumpul: $collectedText'),
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
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationDetailScreen(donation: d),
                      ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: headerColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => DonationFormScreen()),
          ).then((refresh) {
            if (refresh == true) _loadDonations();
          });
        },
      ),
    );
  }
}
