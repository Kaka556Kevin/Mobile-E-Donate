// lib/screens/funds_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/local_fund_service.dart';
import '../models/donation.dart';

class FundsScreen extends StatefulWidget {
  const FundsScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _localService = LocalFundService();
    _initFuture = _initData();
  }

  Future<void> _initData() async {
    await _localService.init();
    final campaigns = await ApiService().fetchAllDonations();
    setState(() {
      _campaigns.clear();
      _campaigns.addAll(campaigns);
      if (_campaigns.isNotEmpty) {
        _selectedCampaign = _campaigns.first.nama;
      }
    });
    if (_selectedCampaign != null) {
      await _loadLocalRecords(_selectedCampaign!);
    }
  }

  Future<void> _loadLocalRecords(String campaignName) async {
    final all = _localService.getAll();
    final campaign = _campaigns.firstWhere((d) => d.nama == campaignName);
    final records = all.where((r) => r.donationId == campaign.id).toList();
    setState(() {
      _localRecords = records;
      _selectedRecordKeys.clear();
    });
  }

  void _onCampaignChanged(String? newName) async {
    if (newName == null) return;
    setState(() => _selectedCampaign = newName);
    await _loadLocalRecords(newName);
  }

  void _onNewCatatan() async {
    if (_selectedCampaign == null) return;
    final campaign = _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
    await Navigator.pushNamed(
      context,
      '/uang-donasi/create',
      arguments: campaign,
    );
    await _loadLocalRecords(_selectedCampaign!);
  }

  double get _sumUangKeluar =>
      _localRecords.fold(0.0, (sum, r) => sum + (r.uangKeluar as num));

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              record.penerima = penerimaCtrl.text;
              record.uangKeluar = num.tryParse(uangCtrl.text) ?? record.uangKeluar;
              await _localService.updateRecord(record.key as int, record);
              await _loadLocalRecords(_selectedCampaign!);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          final campaign = _campaigns.firstWhere((d) => d.nama == _selectedCampaign!);
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _campaigns.map((d) => d.nama).toSet().map(
                        (name) => DropdownMenuItem(value: name, child: Text(name)),
                      ).toList(),
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
                Expanded(
                  child: _localRecords.isEmpty
                      ? const Center(child: Text('Belum ada catatan'))
                      : ListView.builder(
                          itemCount: _localRecords.length,
                          itemBuilder: (_, i) {
                            final r = _localRecords[i];
                            final isSelected = _selectedRecordKeys.contains(r.key as int);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue[50] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          _selectedRecordKeys.add(r.key as int);
                                        } else {
                                          _selectedRecordKeys.remove(r.key as int);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.penerima,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Rp ${_formatCurrency(r.uangKeluar)}'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.green),
                                    onPressed: () => _editRecord(r),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await _localService.deleteRecord(r.key as int);
                                      await _loadLocalRecords(_selectedCampaign!);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
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
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }
}
