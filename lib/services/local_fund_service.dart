// lib/services/local_fund_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:excel/excel.dart';

part 'local_fund_service.g.dart';

@HiveType(typeId: 1)
class FundRecord extends HiveObject {
  @HiveField(0)
  int donationId;
  @HiveField(1)
  String programName;
  @HiveField(2)
  String penerima;
  @HiveField(3)
  num uangKeluar;
  @HiveField(4)
  num sisaSaldo;
  @HiveField(5)
  DateTime timestamp;

  FundRecord({
    required this.donationId,
    required this.programName,
    required this.penerima,
    required this.uangKeluar,
    required this.sisaSaldo,
    required this.timestamp,
  });
}

class LocalFundService {
  static const String _boxName = 'fund_records';

  /// Initialize Hive, register adapter and open box safely
  Future<void> init() async {
    // Ensure Hive is initialized
    await Hive.initFlutter();

    // Register adapter only once
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FundRecordAdapter());
    }

    // Open the box if not already open
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<FundRecord>(_boxName);
    }
  }

  Box<FundRecord> get _box => Hive.box<FundRecord>(_boxName);

  Future<void> addRecord(FundRecord record) async {
    await _box.add(record);
  }

  Future<void> updateRecord(int key, FundRecord record) async {
    await _box.put(key, record);
  }

  Future<void> deleteRecord(int key) async {
    await _box.delete(key);
  }

  List<FundRecord> getAll() {
    return _box.values.toList();
  }

  /// Export to Excel file
  Future<Uint8List> exportToExcel() async {
    var excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow(["ID", "Program", "Penerima", "Uang Keluar", "Sisa Saldo", "Timestamp"]);
    for (var rec in _box.values) {
      sheet.appendRow([
        rec.donationId,
        rec.programName,
        rec.penerima,
        rec.uangKeluar,
        rec.sisaSaldo,
        rec.timestamp.toIso8601String(),
      ]);
    }
    final data = excel.encode();
    if (data == null) throw StateError('Failed to encode Excel data');
    return Uint8List.fromList(data);
  }

  /// Import from an Excel byte array, replacing existing records
  Future<void> importFromExcel(Uint8List bytes) async {
    var excel = Excel.decodeBytes(bytes);
    final rows = excel['Sheet1'].rows;
    await _box.clear();
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final rec = FundRecord(
        donationId: row[0]!.value as int,
        programName: row[1]!.value as String,
        penerima: row[2]!.value as String,
        uangKeluar: row[3]!.value as num,
        sisaSaldo: row[4]!.value as num,
        timestamp: DateTime.parse(row[5]!.value as String),
      );
      await _box.add(rec);
    }
  }
}
