// lib/screens/finance_screen.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../models/uang_donasi.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late Future<List<UangDonasi>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = ApiService().fetchUangDonasi();
  }

  Future<void> _exportExcel(List<UangDonasi> data) async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Nama Donasi');
    sheet.getRangeByName('B1').setText('Uang Masuk');
    sheet.getRangeByName('C1').setText('Uang Keluar');
    sheet.getRangeByName('D1').setText('Sisa Saldo');
    for (var i = 0; i < data.length; i++) {
      final row = i + 2;
      sheet.getRangeByName('A$row').setText(data[i].namaDonasi);
      sheet.getRangeByName('B$row').setNumber(data[i].uangMasuk as double?);
      sheet.getRangeByName('C$row').setNumber(data[i].uangKeluar as double?);
      sheet.getRangeByName('D$row').setNumber(data[i].saldo as double?);
    }
    final bytes = workbook.saveAsStream();
    workbook.dispose();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/uang_donasi.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Keuangan'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              final list = await _futureData;
              _exportExcel(list);
            },
          )
        ],
      ),
      body: FutureBuilder<List<UangDonasi>>(
        future: _futureData,
        builder: (ctx, snap) {
          if (snap.hasData) {
            return DataTable2(
              columns: [
                DataColumn2(label: Text('Nama Donasi'), size: ColumnSize.L),
                DataColumn(label: Text('Uang Masuk')),
                DataColumn(label: Text('Uang Keluar')),
                DataColumn(label: Text('Sisa Saldo')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: snap.data!.map((d) => DataRow(cells: [
                DataCell(Text(d.namaDonasi)),
                DataCell(Text('Rp ${d.uangMasuk}')),
                DataCell(Text('Rp ${d.uangKeluar}')),
                DataCell(Text('Rp ${d.saldo}')),
                DataCell(Row(
                  children: [
                    IconButton(icon: Icon(Icons.edit), onPressed: () {/* edit logic */}),
                    IconButton(icon: Icon(Icons.delete), onPressed: () {/* delete logic */}),
                  ],
                )),
              ])).toList(),
            );
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
