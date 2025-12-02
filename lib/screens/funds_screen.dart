// lib/screens/funds_screen.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../services/local_fund_service.dart';
import '../models/donation.dart';
import 'create_fund_record_screen.dart';

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

  // [BARU] Fungsi Refresh Data (API + Lokal)
  Future<void> _refreshData() async {
    try {
      // 1. Ambil data terbaru dari API
      final campaigns = await ApiService().fetchAllDonations();
      if (!mounted) return;

      setState(() {
        // 2. Update list kampanye
        _campaigns.clear();
        _campaigns.addAll(campaigns);

        // 3. Logika mempertahankan pilihan saat ini
        if (_selectedCampaign != null) {
          // Cek apakah campaign yang dipilih masih ada di list baru
          bool exists = _campaigns.any((d) => d.nama == _selectedCampaign);
          if (!exists && _campaigns.isNotEmpty) {
            _selectedCampaign = _campaigns.first.nama;
          }
        } else if (_campaigns.isNotEmpty) {
          _selectedCampaign = _campaigns.first.nama;
        }
      });

      // 4. Reload catatan lokal
      if (_selectedCampaign != null) {
        await _loadLocalRecords(_selectedCampaign!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diperbarui'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data: $e')),
      );
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
    if (_selectedCampaign == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih kampanye terlebih dahulu')));
      return;
    }
    final camp = _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateFundRecordScreen(campaign: camp)),
    );
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
        title: Text('Edit Catatan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: penerimaCtrl,
                decoration: const InputDecoration(labelText: 'Penerima')),
            TextField(
              controller: uangCtrl,
              decoration: const InputDecoration(labelText: 'Nominal'),
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
        title: const Text('Hapus Catatan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus'))
        ],
      ),
    );

    if (shouldDelete == true) {
      await _localService.deleteRecord(key);
      if (!mounted) return;
      await _loadLocalRecords(_selectedCampaign!);
    }
  }

  void _showFormatOptions({required bool forShare}) {
    if (_selectedRecordKeys.isEmpty) return;
    
    if (forShare) {
      // Tampilan SHARE DIRECT (WhatsApp/Email)
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Bagikan Laporan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.chat_bubble, color: Colors.green),
                  title: Text('WhatsApp', style: GoogleFonts.poppins()),
                  subtitle: Text('Kirim otomatis sebagai PDF', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _processFile(format: ExportFormat.pdf, forShare: true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.redAccent),
                  title: Text('Email', style: GoogleFonts.poppins()),
                  subtitle: Text('Kirim otomatis sebagai PDF', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _processFile(format: ExportFormat.pdf, forShare: true);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Tampilan EXPORT (Save to Device)
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Simpan File', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.green),
                  title: Text('Excel (.xlsx)', style: GoogleFonts.poppins()),
                  onTap: () {
                    Navigator.pop(ctx);
                    _processFile(format: ExportFormat.excel, forShare: false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text('PDF Document (.pdf)', style: GoogleFonts.poppins()),
                  onTap: () {
                    Navigator.pop(ctx);
                    _processFile(format: ExportFormat.pdf, forShare: false);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _processFile({required ExportFormat format, required bool forShare}) async {
    final selRecs = _localRecords
        .where((r) => _selectedRecordKeys.contains(r.key))
        .toList();
    if (selRecs.isEmpty) return;

    setState(() => _isExporting = true);

    try {
      if (!forShare && Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        if (deviceInfo.version.sdkInt < 33) {
          final status = await Permission.storage.request();
          if (!status.isGranted) throw Exception('Izin penyimpanan ditolak.');
        }
      }

      final campaignObj = _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
      final campaignMap = {
        'id': campaignObj.id,
        'nama': campaignObj.nama,
        'target': campaignObj.target,
        'collected': campaignObj.collected,
      };
      final recordsMap = selRecs.map((r) => {
        'penerima': r.penerima,
        'uangKeluar': r.uangKeluar,
      }).toList();

      late final Uint8List bytes;
      final String ext;
      
      if (format == ExportFormat.excel) {
        final res = await compute(_generateExcelBytes, {'records': recordsMap, 'campaign': campaignMap});
        if (res == null) throw Exception('Gagal membuat Excel');
        bytes = res;
        ext = 'xlsx';
      } else {
        final res = await compute(_generatePdfBytes, {'records': recordsMap, 'campaign': campaignMap});
        if (res == null) throw Exception('Gagal membuat PDF');
        bytes = res;
        ext = 'pdf';
      }

      final safeName = _selectedCampaign!.replaceAll(RegExp(r'[^\w\s]+'), '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Laporan_${safeName}_$timestamp.$ext';

      if (forShare) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        if (!mounted) return;
        await Share.shareXFiles(
          [XFile(file.path)], 
          text: 'Laporan Keuangan: $_selectedCampaign'
        );
        
      } else {
        Directory? baseDir = await getApplicationDocumentsDirectory();
        if (Platform.isAndroid) {
          baseDir = await getDownloadsDirectory();
        }
        if (baseDir == null) throw Exception('Direktori tidak ditemukan');

        final targetDir = Directory('${baseDir.path}/edonate/$safeName');
        if (!await targetDir.exists()) await targetDir.create(recursive: true);

        final file = File('${targetDir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tersimpan di: ${file.path}', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e', style: GoogleFonts.poppins())),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  static Future<Uint8List?> _generateExcelBytes(Map<String, dynamic> params) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    
    final headers = ['Penerima', 'Uang Keluar', 'Sisa Saldo', 'Total Masuk', 'Target'];
    for(int i=0; i<headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
    }

    final List recs = params['records'];
    final Map camp = params['campaign'];
    
    double totalKeluar = 0;
    for(var r in recs) totalKeluar += (r['uangKeluar'] as num).toDouble();
    final startSaldo = (camp['collected'] as num).toDouble() - totalKeluar;

    for (var i = 0; i < recs.length; i++) {
      final r = recs[i];
      final row = i + 1;
      
      final currentKeluar = recs.sublist(0, i + 1).fold<double>(0, (p, e) => p + (e['uangKeluar'] as num).toDouble());
      final currentSisa = startSaldo - currentKeluar; 

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = r['penerima'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = r['uangKeluar'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = currentSisa;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = camp['collected'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = camp['target'];
    }
    return Uint8List.fromList(excel.encode()!);
  }

  static Future<Uint8List?> _generatePdfBytes(Map<String, dynamic> params) async {
    final pdf = pw.Document();
    final List recs = params['records'];
    final Map camp = params['campaign'];
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final data = <List<String>>[];
    for(var r in recs) {
      data.add([
        r['penerima'].toString(),
        format.format(r['uangKeluar']),
      ]);
    }

    pdf.addPage(pw.Page(build: (ctx) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Laporan Keuangan: ${camp['nama']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Penerima', 'Nominal'],
            data: data,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ]
      );
    }));
    return await pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4D5BFF);
    final currencyFmt = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Manajemen Dana', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // [MODIFIKASI] Tombol Refresh memanggil _refreshData
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          )
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (_campaigns.isEmpty || _selectedCampaign == null) {
                return Center(child: Text('Tidak ada data kampanye', style: GoogleFonts.poppins(color: Colors.grey)));
              }
              
              final campaign = _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
              final available = campaign.collected - _sumUangKeluar;

              return Column(
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    decoration: BoxDecoration(color: primaryColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
                    child: Column(
                      children: [
                        // View-only Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              dropdownColor: primaryColor,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                              value: _selectedCampaign,
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                              items: _campaigns.map((d) => DropdownMenuItem(value: d.nama, child: Text(d.nama))).toList(),
                              onChanged: _onCampaignChanged,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Balance
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6E7BFB), Color(0xFF9DA6FF)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Dana Tersedia', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                            Text(currencyFmt.format(available), style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  // Action Bar (Buttons)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Checkbox Select All
                        if (_localRecords.isNotEmpty)
                          InkWell(
                            onTap: () => _onSelectAllChanged(!_isAllSelected),
                            child: Row(children: [
                              Checkbox(activeColor: primaryColor, value: _isAllSelected, onChanged: _onSelectAllChanged),
                              Text('Semua', style: GoogleFonts.poppins(fontSize: 12)),
                            ]),
                          ),
                        
                        const Spacer(),

                        // Tombol Export & Share (Hanya muncul jika ada item terpilih)
                        if (_selectedRecordKeys.isNotEmpty) ...[
                          // Tombol Export (Simpan)
                          ElevatedButton.icon(
                            onPressed: () => _showFormatOptions(forShare: false),
                            icon: const Icon(Icons.save_alt_rounded, size: 16),
                            label: const Text('Export'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryColor,
                              elevation: 0,
                              side: const BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tombol Share (Direct WhatsApp/Email)
                          ElevatedButton.icon(
                            onPressed: () => _showFormatOptions(forShare: true),
                            icon: const Icon(Icons.share_rounded, size: 16),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              elevation: 0,
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Tombol Create
                        ElevatedButton.icon(
                          onPressed: _onNewCatatan,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Catat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List Data
                  Expanded(
                    child: _localRecords.isEmpty
                        ? Center(child: Text('Belum ada catatan', style: GoogleFonts.poppins(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _localRecords.length,
                            itemBuilder: (_, i) {
                              final r = _localRecords[i];
                              final isSelected = _selectedRecordKeys.contains(r.key);
                              return GestureDetector(
                                onTap: () => _onSingleRecordToggled(r, !isSelected),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected ? Border.all(color: primaryColor, width: 1.5) : null,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
                                  ),
                                  child: Row(children: [
                                    Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? primaryColor : Colors.grey[300]),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(r.penerima, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                      Text(DateFormat('dd MMM').format(r.timestamp), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                                    ])),
                                    Text('- ${currencyFmt.format(r.uangKeluar)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                                    IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey), onPressed: () => _confirmDeleteRecord(r.key))
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          if (_isExporting) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}

enum ExportFormat { excel, pdf }