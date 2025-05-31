// lib/screens/funds_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // untuk request permission
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/api_service.dart';
import '../services/local_fund_service.dart';
import '../models/donation.dart';

// ========== FUNDS SCREEN ==========

class FundsScreen extends StatefulWidget {
  const FundsScreen({super.key});

  @override
  _FundsScreenState createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  String? _selectedCampaign;
  final List<Donation> _campaigns = [];
  List<FundRecord> _localRecords = [];
  final Set<int> _selectedRecordKeys = {};
  late Future<void> _initFuture;
  late LocalFundService _localService;

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _localService = LocalFundService();
    _initFuture = _initData();
  }

  Future<void> _initData() async {
    await _localService.init();
    final campaigns = await ApiService().fetchAllDonations();
    if (!mounted) return;
    setState(() {
      _campaigns
        ..clear()
        ..addAll(campaigns);
      if (_campaigns.isNotEmpty) {
        _selectedCampaign = _campaigns.first.nama;
      }
    });
    if (_selectedCampaign != null) {
      await _loadLocalRecords(_selectedCampaign!);
    }
  }

  Future<void> _loadLocalRecords(String campaignName) async {
    final allRecords = _localService.getAll();
    final campaign = _campaigns.firstWhere((d) => d.nama == campaignName);
    final matched = allRecords.where((r) => r.donationId == campaign.id).toList();
    if (!mounted) return;
    setState(() {
      _localRecords = matched;
      _selectedRecordKeys.clear();
    });
  }

  void _onCampaignChanged(String? newName) async {
    if (newName == null || !mounted) return;
    setState(() => _selectedCampaign = newName);
    await _loadLocalRecords(newName);
  }

  void _onNewCatatan() async {
    if (_selectedCampaign == null) return;
    final camp = _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
    await Navigator.pushNamed(context, '/uang-donasi/create', arguments: camp);
    if (!mounted) return;
    await _loadLocalRecords(_selectedCampaign!);
  }

  double get _sumUangKeluar =>
      _localRecords.fold(0.0, (sum, r) => sum + (r.uangKeluar));

  Future<void> _editRecord(FundRecord record) async {
    final penerimaCtrl = TextEditingController(text: record.penerima);
    final uangCtrl = TextEditingController(text: record.uangKeluar.toString());
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: penerimaCtrl,
              decoration: const InputDecoration(labelText: 'Penerima'),
            ),
            TextField(
              controller: uangCtrl,
              decoration: const InputDecoration(labelText: 'Uang Keluar'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              record.penerima = penerimaCtrl.text;
              record.uangKeluar =
                  num.tryParse(uangCtrl.text) ?? record.uangKeluar;
              await _localService.updateRecord(record.key!, record);
              if (!mounted) return;
              await _loadLocalRecords(_selectedCampaign!);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  bool get _isAllSelected {
    if (_localRecords.isEmpty) return false;
    return _selectedRecordKeys.length == _localRecords.length;
  }

  void _onSelectAllChanged(bool? newVal) {
    if (newVal == null) return;
    setState(() {
      if (newVal) {
        for (var r in _localRecords) {
          if (r.key != null) _selectedRecordKeys.add(r.key!);
        }
      } else {
        _selectedRecordKeys.clear();
      }
    });
  }

  void _onSingleRecordToggled(FundRecord record, bool? checked) {
    if (checked == null) return;
    setState(() {
      if (checked) {
        _selectedRecordKeys.add(record.key!);
      } else {
        _selectedRecordKeys.remove(record.key!);
      }
    });
  }

  /// ==================== METODE EXPORT ====================

  Future<void> _exportSelectedToExcel() async {
    final selRecs = _localRecords
        .where((r) => _selectedRecordKeys.contains(r.key!))
        .toList();
    if (selRecs.isEmpty) return;

    // Step 1: minta permission (jika di Android)
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final req = await Permission.storage.request();
        if (!req.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission storage ditolak')),
          );
          return;
        }
      }
    }

    // Step 2: ubah data ke Map<String, dynamic> agar compute() jadi cepat
    final campaignObj = _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
    final Map<String, dynamic> campaignMap = {
      'id': campaignObj.id,
      'nama': campaignObj.nama,
      'target': campaignObj.target,
      'collected': campaignObj.collected,
    };
    final List<Map<String, dynamic>> recordsMap = selRecs
        .map((rec) => {
              'penerima': rec.penerima,
              'uangKeluar': rec.uangKeluar,
            })
        .toList();

    setState(() => _isExporting = true);

    try {
      // Panggil isolate untuk generate .xlsx
      final String? resultPath = await compute(
  _generateExcelAndSave,
  <String, dynamic>{
    'records': recordsMap,
    'campaign': campaignMap,
  },
);

      if (!mounted) return;
      if (resultPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat file Excel')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File tersimpan di: $resultPath')),
        );
        await Share.shareXFiles([XFile(resultPath)],
            text: 'Berikut file Excel catatan donasi Anda.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat export: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isExporting = false);
    }
  }
  /// Fungsi untuk generate file Excel dan menyimpannya
  static Future<String?> _generateExcelAndSave(Map<String, dynamic> params) async {
    final List<dynamic> recs = params['records'] as List<dynamic>;
    final Map<String, dynamic> camp = params['campaign'] as Map<String, dynamic>;

    // 1) Buat workbook baru
    final excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final sheetObject = excel[sheetName];

    // 2) Tulis header
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'Nama Donasi';
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Uang Masuk';
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Uang Keluar';
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Sisa Saldo';

    // 3) Hitung sumKeluar & sisaSaldo
    double sumKeluar = 0.0;
    for (var recMap in recs) {
      sumKeluar += (recMap['uangKeluar'] as num).toDouble();
    }
    final availableSaldo =
        (camp['collected'] as num).toDouble() - sumKeluar;

    // 4) Tulis data per baris (mulai rowIndex = 1)
    for (var i = 0; i < recs.length; i++) {
      final recMap = recs[i] as Map;
      final row = i + 1;
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = recMap['penerima'];
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = 0;
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = recMap['uangKeluar'];
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = availableSaldo;
    }

    // 5) Encode ke bytes
    final fileBytes = excel.encode();
    if (fileBytes == null) return null;

    try {
      // 6) Cari folder Download (Android) atau Documents (iOS)
      Directory baseDir;
      if (Platform.isAndroid) {
        baseDir = Directory('/storage/emulated/0/Download');
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      // 7) Pastikan folder Download ada; jika tidak, buat
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      // 8) Simpan file dengan ekstensi .xlsx
      final fileName =
          'uang_donasi_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${baseDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      return filePath;
    } catch (_) {
      return null;
    }
  }

  /// ==================== END EXPORT ====================

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Uang Donasi')),
          body: FutureBuilder<void>(
            future: _initFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_campaigns.isEmpty) {
                return const Center(child: Text('Tidak ada kampanye'));
              }
              final campaign =
                  _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
              final available = campaign.collected - _sumUangKeluar;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Pilih Kampanye',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _campaigns
                          .map((d) => d.nama)
                          .toSet()
                          .map(
                              (name) => DropdownMenuItem(value: name, child: Text(name)))
                          .toList(),
                      value: _selectedCampaign,
                      onChanged: _onCampaignChanged,
                    ),
                    const SizedBox(height: 16),
                    _buildCard('Target', _formatCurrency(campaign.target)),
                    const SizedBox(height: 8),
                    _buildCard('Terkumpul', _formatCurrency(campaign.collected)),
                    const SizedBox(height: 8),
                    _buildCard('Tersedia', _formatCurrency(available)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _onNewCatatan,
                      icon: const Icon(Icons.add),
                      label: const Text('New Catatan'),
                    ),
                    const SizedBox(height: 16),
                    if (_localRecords.isNotEmpty)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Select All'),
                        value: _isAllSelected,
                        onChanged: _onSelectAllChanged,
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _localRecords.isEmpty
                          ? const Center(child: Text('Belum ada catatan'))
                          : ListView.builder(
                              itemCount: _localRecords.length,
                              itemBuilder: (_, i) {
                                final r = _localRecords[i];
                                final isSelected =
                                    _selectedRecordKeys.contains(r.key!);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue[50]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (v) =>
                                            _onSingleRecordToggled(r, v),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r.penerima,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rp ${_formatCurrency(r.uangKeluar)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.green),
                                        onPressed: () => _editRecord(r),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          await _localService.deleteRecord(r.key!);
                                          if (!mounted) return;
                                          await _loadLocalRecords(
                                              _selectedCampaign!);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_selectedRecordKeys.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.file_download_outlined),
                          label: Text(
                            'Export (${_selectedRecordKeys.length} item${_selectedRecordKeys.length > 1 ? 's' : ''})',
                          ),
                          onPressed: _exportSelectedToExcel,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_isExporting)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }
}
