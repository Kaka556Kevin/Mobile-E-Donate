// lib/screens/finance_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../models/donation.dart';
import '../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late Future<List<Donation>> _futureDonations;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    setState(() {
      _futureDonations = ApiService().fetchAllDonations();
    });
  }

  Future<void> _exportExcel(List<Donation> list) async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Nama Kampanye');
    sheet.getRangeByName('B1').setText('Target');
    sheet.getRangeByName('C1').setText('Terkumpul');
    sheet.getRangeByName('D1').setText('Status');

    for (var i = 0; i < list.length; i++) {
      final d = list[i];
      sheet.getRangeByName('A\$row').setText(d.nama);
      sheet.getRangeByName('B\$row').setNumber(d.target);
      sheet.getRangeByName('C\$row').setNumber(d.collected.toDouble());
      sheet.getRangeByName('D\$row').setText(
            d.collected >= d.target ? 'Selesai' : 'Aktif',
          );
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    final file = File('\${dir.path}/donations_finance.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data diekspor ke \${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final list = await _futureDonations;
              _exportExcel(list);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Donation>>(
        future: _futureDonations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            columns: const [
              DataColumn2(label: Text('Nama Kampanye'), size: ColumnSize.L),
              DataColumn(label: Text('Target')),
              DataColumn(label: Text('Terkumpul')),
              DataColumn(label: Text('Status')),
            ],
            rows: data.map((d) {
              return DataRow(cells: [
                DataCell(Text(d.nama)),
                const DataCell(Text('Rp \${d.target.toInt()}')),
                const DataCell(Text('Rp \${d.collected.toInt()}')),
                DataCell(Text(
                  d.collected >= d.target ? 'Selesai' : 'Aktif',
                )),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }
}
