// lib/screens/funds_screen.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart'; // <-- MODIFIKASI: Import baru
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Ganti import ini dengan path yang benar ke model dan service Anda
import '../services/api_service.dart';
import '../services/local_fund_service.dart';
import '../models/donation.dart';

class FundsScreen extends StatefulWidget {
  const FundsScreen({super.key});

  @override
  State<FundsScreen> createState() => _FundsScreenState();
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
    try {
      final campaign = _campaigns.firstWhere((d) => d.nama == campaignName);
      final matched =
          allRecords.where((r) => r.donationId == campaign.id).toList();
      if (!mounted) return;
      setState(() {
        _localRecords = matched;
        _selectedRecordKeys.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localRecords = [];
        _selectedRecordKeys.clear();
      });
    }
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
                decoration: const InputDecoration(labelText: 'Penerima')),
            TextField(
              controller: uangCtrl,
              decoration: const InputDecoration(labelText: 'Uang Keluar'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              record.penerima = penerimaCtrl.text;
              record.uangKeluar =
                  num.tryParse(uangCtrl.text) ?? record.uangKeluar;
              await _localService.updateRecord(record.key, record);
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
          if (r.key != null) _selectedRecordKeys.add(r.key);
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
        _selectedRecordKeys.add(record.key);
      } else {
        _selectedRecordKeys.remove(record.key);
      }
    });
  }

  Future<void> _confirmDeleteRecord(int key) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _localService.deleteRecord(key);
      if (!mounted) return;
      await _loadLocalRecords(_selectedCampaign!);
    }
  }

  void _showExportOptions() {
    if (_selectedRecordKeys.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export to Excel (.xlsx)'),
              onTap: () {
                Navigator.pop(ctx);
                _exportSelected(format: ExportFormat.excel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export to PDF (.pdf)'),
              onTap: () {
                Navigator.pop(ctx);
                _exportSelected(format: ExportFormat.pdf);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // =======================================================================
  // =================== MODIFIKASI DIMULAI DI SINI ========================
  // =======================================================================
  Future<void> _exportSelected({required ExportFormat format}) async {
    final selRecs = _localRecords
        .where((r) => _selectedRecordKeys.contains(r.key))
        .toList();
    if (selRecs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih setidaknya satu catatan untuk diekspor.')));
      return;
    }

    setState(() => _isExporting = true);

    try {
      bool permissionGranted = false;

      // Logika permintaan izin yang baru
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        // Untuk Android 13 (SDK 33) ke atas, TIDAK PERLU IZIN untuk menyimpan ke folder Downloads
        if (deviceInfo.version.sdkInt >= 33) {
          permissionGranted = true;
        } else {
          // Untuk Android 12 ke bawah, kita tetap meminta izin storage
          final status = await Permission.storage.request();
          permissionGranted = status.isGranted;
        }
      } else {
        // Untuk iOS dan platform lain, anggap izin ada
        permissionGranted = true;
      }

      if (!permissionGranted) {
        throw Exception('Izin penyimpanan ditolak. Tidak dapat melanjutkan.');
      }

      // Kode untuk membuat file (tidak ada yang berubah dari sini ke bawah)
      final campaignObj =
          _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
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

      late final Uint8List bytes;
      final String ext;
      if (format == ExportFormat.excel) {
        final res = await compute(_generateExcelBytes,
            {'records': recordsMap, 'campaign': campaignMap});
        if (res == null) throw Exception('Gagal membuat file Excel');
        bytes = res;
        ext = 'xlsx';
      } else {
        final res = await compute(_generatePdfBytes,
            {'records': recordsMap, 'campaign': campaignMap});
        if (res == null) throw Exception('Gagal membuat file PDF');
        bytes = res;
        ext = 'pdf';
      }

      Directory? baseDir = await getApplicationDocumentsDirectory(); // Default
      if (Platform.isAndroid) {
        baseDir = await getDownloadsDirectory();
      }

      if (baseDir == null) {
        throw Exception('Gagal menemukan direktori penyimpanan.');
      }

      final edonateDir =
          Directory('${baseDir.path}/edonate/${_selectedCampaign!}');
      if (!await edonateDir.exists()) {
        await edonateDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'fund_records_$timestamp.$ext';
      final filePath = '${edonateDir.path}/$fileName';
      final outFile = File(filePath);
      await outFile.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File tersimpan di: $filePath')));

      await Share.shareXFiles([XFile(filePath)],
          text: 'Berikut file catatan donasi.');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saat export: $e')));
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
  // =======================================================================
  // =================== MODIFIKASI BERAKHIR DI SINI =======================
  // =======================================================================

  static Future<Uint8List?> _generateExcelBytes(
      Map<String, dynamic> params) async {
    final List<dynamic> recs = params['records'] as List<dynamic>;
    final Map<String, dynamic> camp =
        params['campaign'] as Map<String, dynamic>;

    final excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheetObject = excel[sheetName];

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'Penerima';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = 'Uang Keluar';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = 'Sisa Saldo';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
        .value = 'Uang Masuk';
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
        .value = 'Target';

    double sumKeluar = 0.0;
    for (var rec in recs) {
      sumKeluar += (rec['uangKeluar'] as num).toDouble();
    }

    final startingSaldo = (camp['collected'] as num).toDouble() - sumKeluar;

    for (var i = 0; i < recs.length; i++) {
      final rec = recs[i] as Map;
      final row = i + 1;
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = rec['penerima'].toString();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = (rec['uangKeluar'] as num).toDouble();
      final cumulativeKeluar = recs.sublist(0, i + 1).fold<double>(
          0.0, (s, r2) => s + (r2['uangKeluar'] as num).toDouble());
      final rowSaldo = startingSaldo - cumulativeKeluar;
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = rowSaldo;
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = (camp['collected'] as num).toDouble();
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = (camp['target'] as num).toDouble();
    }

    final fileBytes = excel.encode();
    if (fileBytes == null) return null;
    return Uint8List.fromList(fileBytes);
  }

  static Future<Uint8List?> _generatePdfBytes(
      Map<String, dynamic> params) async {
    final List<dynamic> recs = params['records'] as List<dynamic>;
    final Map<String, dynamic> camp =
        params['campaign'] as Map<String, dynamic>;

    final pdf = pw.Document();
    final headers = [
      'Penerima',
      'Uang Keluar',
      'Sisa Saldo',
      'Uang Masuk',
      'Target'
    ];
    final List<List<String>> data = [];

    double sumKeluar = 0.0;
    for (var rec in recs) {
      sumKeluar += (rec['uangKeluar'] as num).toDouble();
    }
    final startingSaldo = (camp['collected'] as num).toDouble() - sumKeluar;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    for (var i = 0; i < recs.length; i++) {
      final rec = recs[i] as Map;
      final cumulativeKeluar = recs.sublist(0, i + 1).fold<double>(
          0.0, (s, r2) => s + (r2['uangKeluar'] as num).toDouble());
      final rowSaldo = startingSaldo - cumulativeKeluar;
      data.add([
        rec['penerima'].toString(),
        formatter.format(rec['uangKeluar']),
        formatter.format(rowSaldo),
        formatter.format(camp['collected']),
        formatter.format(camp['target']),
      ]);
    }

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Uang Donasi - ${camp['nama']}',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                  headers: headers,
                  data: data,
                  cellAlignment: pw.Alignment.centerLeft),
            ]);
      },
    ));

    final bytes = await pdf.save();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: const Text('Uang Donasi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_selectedCampaign != null) {
                  _loadLocalRecords(_selectedCampaign!);
                }
              },
            )
          ],
        ),
        body: FutureBuilder<void>(
          future: _initFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_campaigns.isEmpty || _selectedCampaign == null) {
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
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _campaigns
                          .map((d) => d.nama)
                          .toSet()
                          .map((name) =>
                              DropdownMenuItem(value: name, child: Text(name)))
                          .toList(),
                      value: _selectedCampaign,
                      onChanged: _onCampaignChanged,
                    ),
                    const SizedBox(height: 16),
                    _buildCard('Target', _formatCurrency(campaign.target)),
                    const SizedBox(height: 8),
                    _buildCard(
                        'Terkumpul', _formatCurrency(campaign.collected)),
                    const SizedBox(height: 8),
                    _buildCard('Tersedia', _formatCurrency(available)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                        onPressed: _onNewCatatan,
                        icon: const Icon(Icons.add),
                        label: const Text('New Catatan')),
                    const SizedBox(height: 16),
                    if (_localRecords.isNotEmpty)
                      CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Select All'),
                          value: _isAllSelected,
                          onChanged: _onSelectAllChanged),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _localRecords.isEmpty
                          ? const Center(child: Text('Belum ada catatan'))
                          : ListView.builder(
                              itemCount: _localRecords.length,
                              itemBuilder: (_, i) {
                                final r = _localRecords[i];
                                final isSelected =
                                    _selectedRecordKeys.contains(r.key);
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
                                            : Colors.grey[300]!),
                                  ),
                                  child: Row(children: [
                                    Checkbox(
                                        value: isSelected,
                                        onChanged: (v) =>
                                            _onSingleRecordToggled(r, v)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(r.penerima,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(height: 4),
                                            Text(_formatCurrency(r.uangKeluar)),
                                          ]),
                                    ),
                                    IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.green),
                                        onPressed: () => _editRecord(r)),
                                    IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _confirmDeleteRecord(r.key)),
                                  ]),
                                );
                              },
                            ),
                    ),
                    if (_selectedRecordKeys.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Export'),
                          onPressed: _showExportOptions,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48)),
                        ),
                      ),
                  ]),
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
          ),
        ),
    ]);
  }

  Widget _buildCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }
}

enum ExportFormat { excel, pdf }
