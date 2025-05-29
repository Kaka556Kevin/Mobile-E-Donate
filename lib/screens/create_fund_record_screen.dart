// lib/screens/create_fund_record_screen.dart
import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class CreateFundRecordScreen extends StatefulWidget {
  @override
  _CreateFundRecordScreenState createState() => _CreateFundRecordScreenState();
}

class _CreateFundRecordScreenState extends State<CreateFundRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<Donation> _campaignFuture;
  String _penerima = '';
  num _uangKeluar = 0;
  num _sisaSaldo = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // no more context-dependent calls here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // now it's safe to grab ModalRoute.of(context)
    _campaignFuture = _fetchCampaign();
  }

  Future<Donation> _fetchCampaign() async {
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is Donation) {
      return arg;
    } else {
      final list = await ApiService().fetchAllDonations();
      if (arg is String) {
        return list.firstWhere((d) => d.nama == arg, orElse: () => list.first);
      }
      return list.first;
    }
  }

  void _onKeluarChanged(String val, Donation campaign) {
    final parsed = num.tryParse(val.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    setState(() {
      _uangKeluar = parsed;
      _sisaSaldo = (campaign.target - campaign.collected) - _uangKeluar;
    });
  }

  Future<void> _submit(Donation campaign) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      final payload = {
        'donation_id': campaign.id,
        'penerima_sumbangan': _penerima,
        'uang_keluar': _uangKeluar,
        'sisa_saldo': _sisaSaldo,
      };
      await ApiService().createUangDonasi(payload);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _format(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Catatan')),
      body: FutureBuilder<Donation>(
        future: _campaignFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final campaign = snapshot.data!;
          // initialize sisaSaldo on first load
          if (_sisaSaldo == 0) {
            _sisaSaldo = campaign.target - campaign.collected;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Program Donasi: ${campaign.nama}'),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Penerima Sumbangan'),
                    validator: (v) =>
                        v!.isEmpty ? 'Wajib diisi' : null,
                    onSaved: (v) => _penerima = v!.trim(),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Uang Keluar (Rp)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _onKeluarChanged(v, campaign),
                    validator: (v) =>
                        (num.tryParse(v!.replaceAll('.', '')) ?? 0) <= 0
                            ? 'Masukkan angka valid'
                            : null,
                    onSaved: (v) =>
                        _uangKeluar = num.tryParse(v!.replaceAll('.', '')) ?? 0,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Sisa Saldo: ${_format(_sisaSaldo)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : () => _submit(campaign),
                    child: _loading
                        ? CircularProgressIndicator()
                        : Text('Create'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
