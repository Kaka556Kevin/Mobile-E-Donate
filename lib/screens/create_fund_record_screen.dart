// lib/screens/create_fund_record_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../services/local_fund_service.dart';
import '../services/api_service.dart';

class CreateFundRecordScreen extends StatefulWidget {
  const CreateFundRecordScreen({Key? key}) : super(key: key);

  @override
  _CreateFundRecordScreenState createState() => _CreateFundRecordScreenState();
}

class _CreateFundRecordScreenState extends State<CreateFundRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late LocalFundService _localService;
  late Future<List<Donation>> _donationsFuture;
  Donation? _selectedCampaign;
  String _penerima = '';
  num _uangKeluar = 0;
  num _sisaSaldo = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _localService = LocalFundService();
    _localService.init();
    _donationsFuture = ApiService().fetchAllDonations();
  }

  void _onCampaignChanged(Donation? newCampaign) {
    if (newCampaign == null) return;
    setState(() {
      _selectedCampaign = newCampaign;
      _uangKeluar = 0;
      // start available equal to collected
      _sisaSaldo = newCampaign.collected;
    });
  }

  void _onKeluarChanged(String val) {
    if (_selectedCampaign == null) return;
    final parsed = num.tryParse(val.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    setState(() {
      _uangKeluar = parsed;
      // subtract from collected, not target
      _sisaSaldo = _selectedCampaign!.collected - _uangKeluar;
    });
  }

  Future<void> _submit() async {
    if (_selectedCampaign == null) return;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      final record = FundRecord(
        donationId: _selectedCampaign!.id,
        programName: _selectedCampaign!.nama,
        penerima: _penerima,
        uangKeluar: _uangKeluar,
        sisaSaldo: _sisaSaldo,
        timestamp: DateTime.now(),
      );
      await _localService.addRecord(record);
      // reset form and available
      _formKey.currentState!.reset();
      setState(() {
        _uangKeluar = 0;
        _sisaSaldo = _selectedCampaign!.collected;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error menyimpan: \$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _deleteRecord(int key) async {
    await _localService.deleteRecord(key);
    setState(() {});
  }

  String _format(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+\b)'),
      (m) => '\${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Catatan')),
      body: FutureBuilder<List<Donation>>(
        future: _donationsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data!.isEmpty) {
            return const Center(child: Text('Tidak ada program donasi tersedia'));
          }
          final donations = snap.data!;
          _selectedCampaign ??= donations.first;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown
                DropdownButton<Donation>(
                  value: _selectedCampaign,
                  isExpanded: true,
                  items: donations
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.nama),
                          ))
                      .toList(),
                  onChanged: _onCampaignChanged,
                ),
                const SizedBox(height: 12),
                Text('Target: Rp ${_format(_selectedCampaign!.target)}'),
                Text('Terkumpul: Rp ${_format(_selectedCampaign!.collected)}'),
                Text('Tersedia: Rp ${_format(_sisaSaldo)}'),
                const Divider(height: 32),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Penerima Sumbangan'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        onSaved: (v) => _penerima = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Uang Keluar (Rp)'),
                        keyboardType: TextInputType.number,
                        onChanged: _onKeluarChanged,
                        validator: (v) =>
                            (num.tryParse(v!.replaceAll('.', '')) ?? 0) <= 0
                                ? 'Masukkan angka valid'
                                : null,
                        onSaved: (v) => _uangKeluar =
                            num.tryParse(v!.replaceAll('.', '')) ?? 0,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('Simpan Catatan'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // List of records
                Expanded(
                  child: FutureBuilder<List<FundRecord>>(
                    future: Future.value(_localService.getAll()
                        .where((r) => r.donationId ==
                            _selectedCampaign!.id)
                        .toList()),
                    builder: (context, recSnap) {
                      final records = recSnap.data ?? [];
                      if (records.isEmpty) {
                        return const Center(child: Text('Belum ada catatan'));
                      }
                      return ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, i) {
                          final rec = records[i];
                          return Card(
                            child: ListTile(
                              title: Text(rec.penerima),
                              subtitle: Text(
                                  'Rp ${_format(rec.uangKeluar)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    _deleteRecord(rec.key as int),
                              ),
                            ),
                          );
                        },
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
}
