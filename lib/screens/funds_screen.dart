// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import '../services/api_service.dart';

// // class FundsScreen extends StatefulWidget {
// //   @override
// //   _FundsScreenState createState() => _FundsScreenState();
// // }

// // class _FundsScreenState extends State<FundsScreen> {
// //   String? _selectedCampaign;
// //   List<String> _campaigns = [];
// //   late Future<FundDetail> _futureDetail;

// //   @override
// //   void initState() {
// //     super.initState();
// //     ApiService().fetchKelolaDonasi().then((list) => setState(() => _campaigns = list.map((k) => k.nama).toList()));
// //   }

// //   void _loadDetail() {
// //     if (_selectedCampaign != null) {
// //       setState(() => _futureDetail = ApiService().fetchFundDetail(_selectedCampaign!));
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     const headerColor = Color(0xFF4D5BFF);

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.stretch,
// //       children: [
// //         Container(
// //           color: headerColor,
// //           padding: EdgeInsets.only(top: 48, bottom: 24, left: 24),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text('Uang Donasi',
// //                   style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
// //               SizedBox(height: 4),
// //               Text('Melacak Pemasukan dan Pengeluaran', style: TextStyle(color: Colors.white70)),
// //             ],
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Padding(
// //           padding: EdgeInsets.symmetric(horizontal: 16),
// //           child: DropdownButtonFormField<String>(
// //             decoration: InputDecoration(
// //               hintText: 'Pilih Kampanye',
// //               filled: true,
// //               fillColor: Colors.white,
// //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// //               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //             ),
// //             items: _campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
// //             onChanged: (v) => setState(() {
// //               _selectedCampaign = v;
// //               _loadDetail();
// //             }),
// //           ),
// //         ),
// //         SizedBox(height: 16),
// //         Expanded(
// //           child: FutureBuilder<FundDetail>(
// //             future: _futureDetail,
// //             builder: (ctx, snap) {
// //               if (snap.hasData) {
// //                 final d = snap.data!;
// //                 return Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 16),
// //                   child: ListView(
// //                     children: [
// //                       _infoCard('Total Terkumpul', 'Rp ${d.collectedFormatted}'),
// //                       Row(
// //                         children: [
// //                           _infoCard('Pengeluaran', 'Rp ${d.spentFormatted}'),
// //                           _infoCard('Tersedia', 'Rp ${d.availableFormatted}'),
// //                         ],
// //                       ),
// //                       SizedBox(height: 16),
// //                       Text('Pengeluaran Terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
// //                       ...d.recentExpenses.map((e) => _expenseItem(e)).toList(),
// //                     ],
// //                   ),
// //                 );
// //               } else if (snap.hasError) {
// //                 return Center(child: Text('Error: ${snap.error}'));
// //               }
// //               return Center(child: Text('Pilih kampanye untuk melihat detail.'));
// //             },
// //           ),
// //         ),
// //         Padding(
// //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           child: SizedBox(
// //             width: double.infinity,
// //             height: 48,
// //             child: ElevatedButton(
// //               style: ElevatedButton.styleFrom(backgroundColor: headerColor),
// //               onPressed: () {
// //                 // Navigator.push ke form tambah pengeluaran
// //               },
// //               child: Text('Tambah Pengeluaran', style: TextStyle(color: Colors.white)),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _infoCard(String title, String value) {
// //     return Expanded(
// //       child: Container(
// //         margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
// //         padding: EdgeInsets.all(12),
// //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(title, style: TextStyle(color: Colors.grey[600])),
// //             SizedBox(height: 8),
// //             Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _expenseItem(Expense e) {
// //     return Container(
// //       margin: EdgeInsets.symmetric(vertical: 6),
// //       padding: EdgeInsets.all(12),
// //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //             Text(e.description, style: TextStyle(fontWeight: FontWeight.w600)),
// //             SizedBox(height: 4),
// //             Text(e.dateFormatted, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
// //           ]),
// //           Text('Rp ${e.amountFormatted}'),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // /// Model hasil API:
// // class FundDetail {
// //   final int collected;
// //   final int spent;
// //   final List<Expense> recentExpenses;
// //   FundDetail({required this.collected, required this.spent, required this.recentExpenses});

// //   String get collectedFormatted => _fmt(collected);
// //   String get spentFormatted => _fmt(spent);
// //   String get availableFormatted => _fmt(collected - spent);

// //   String _fmt(int v) => NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(v);
// // }

// // class Expense {
// //   final String description;
// //   final DateTime date;
// //   final int amount;
// //   Expense({required this.description, required this.date, required this.amount});

// //   String get dateFormatted => DateFormat.yMMMMd('en_US').format(date);
// //   String get amountFormatted => NumberFormat.compact(locale: 'en_US').format(amount);
// // }

// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../models/fund_detail.dart';
// import '../models/expense.dart';

// class FundsScreen extends StatefulWidget {
//   @override
//   _FundsScreenState createState() => _FundsScreenState();
// }

// class _FundsScreenState extends State<FundsScreen> {
//   String? _selectedCampaign;
//   List<String> _campaigns = [];
//   Future<FundDetail>? _futureDetail;

//   @override
//   void initState() {
//     super.initState();
//     ApiService()
//         .fetchKelolaDonasi()
//         .then((list) => setState(() {
//               _campaigns = list.map((k) => k.nama).toList();
//             }))
//         .catchError((e) => debugPrint('Error fetchKelolaDonasi: $e'));
//   }

//   void _loadDetail() {
//     if (_selectedCampaign != null) {
//       setState(() {
//         _futureDetail = ApiService().fetchFundDetail(_selectedCampaign!);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const headerColor = Color(0xFF4D5BFF);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Container(
//           color: headerColor,
//           padding: EdgeInsets.only(top: 48, bottom: 24, left: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Uang Donasi',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold)),
//               SizedBox(height: 4),
//               Text('Melacak Pemasukan dan Pengeluaran', style: TextStyle(color: Colors.white70)),
//             ],
//           ),
//         ),
//         SizedBox(height: 16),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: DropdownButtonFormField<String>(
//             decoration: InputDecoration(
//               hintText: 'Pilih Kampanye',
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             ),
//             items: _campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//             onChanged: (v) {
//               setState(() {
//                 _selectedCampaign = v;
//                 _loadDetail();
//               });
//             },
//           ),
//         ),
//         SizedBox(height: 16),
//         Expanded(
//           child: _futureDetail == null
//               ? Center(child: Text('Pilih kampanye untuk melihat detail.'))
//               : FutureBuilder<FundDetail>(
//                   future: _futureDetail,
//                   builder: (ctx, snap) {
//                     if (snap.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snap.hasError) {
//                       return Center(child: Text('Error: \${snap.error}'));
//                     } else if (!snap.hasData) {
//                       return Center(child: Text('Data kosong.'));
//                     }

//                     final d = snap.data!;
//                     return Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: ListView(
//                         children: [
//                           _infoCard('Total Terkumpul', d.collectedFormatted),
//                           Row(
//                             children: [
//                               _infoCard('Pengeluaran', d.spentFormatted),
//                               _infoCard('Tersedia', d.availableFormatted),
//                             ],
//                           ),
//                           SizedBox(height: 16),
//                           Text('Pengeluaran Terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
//                           ...d.recentExpenses.map((e) => _expenseItem(e)).toList(),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: headerColor),
//               onPressed: () {
//                 // Navigator.push ke form tambah pengeluaran
//               },
//               child: Text('Tambah Pengeluaran', style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _infoCard(String title, String value) {
//     return Expanded(
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: TextStyle(color: Colors.grey[600])),
//             SizedBox(height: 8),
//             Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _expenseItem(Expense e) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 6),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(e.description, style: TextStyle(fontWeight: FontWeight.w600)),
//             SizedBox(height: 4),
//             Text(e.dateFormatted, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           ]),
//           Text('Rp \${e.amountFormatted}'),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/fund_detail.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class FundsScreen extends StatefulWidget {
  @override
  _FundsScreenState createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  List<String> _campaigns = [];
  String? _sel;
  Future<FundDetail>? _futureDetail;

  @override
  void initState() {
    super.initState();
    ApiService().fetchKelolaDonasi().then((list) {
      setState(() => _campaigns = list.map((e) => e.nama).toList());
    });
  }

  void _onChange(String? v) {
    setState(() {
      _sel = v;
      _futureDetail = ApiService().fetchFundDetail(v!);
    });
  }

  Widget _infoCard(String title, String value) => Expanded(
        child: Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(12),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
      );

  Widget _expenseItem(Expense e) => Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.description, style: TextStyle(fontWeight: FontWeight.w600)),
            Text(e.dateFormatted, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ]),
          Text(e.amountFormatted),
        ]),
      );

  @override
  Widget build(BuildContext ctx) {
    final headerColor = Color(0xFF4D5BFF);
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: headerColor,
          padding: EdgeInsets.only(top: 48, bottom: 24, left: 24),
          child: Text('Uang Donasi',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Pilih Kampanye',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: _campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: _onChange,
          ),
        ),
        Expanded(
          child: _futureDetail == null
              ? Center(child: Text('Pilih kampanye untuk lihat detail'))
              : FutureBuilder<FundDetail>(
                  future: _futureDetail,
                  builder: (c, s) {
                    if (s.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    if (s.hasError) return Center(child: Text('Error: ${s.error}'));
                    final d = s.data!;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(children: [
                        Row(children: [
                          _infoCard('Terkumpul', d.collectedFormatted),
                          _infoCard('Pengeluaran', d.spentFormatted),
                          _infoCard('Tersedia', d.availableFormatted),
                        ]),
                        SizedBox(height: 16),
                        Text('Pengeluaran Terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...d.recentExpenses.map(_expenseItem),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
