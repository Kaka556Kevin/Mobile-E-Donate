// lib/screens/create_fund_record_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../services/local_fund_service.dart';

class CreateFundRecordScreen extends StatefulWidget {
  // [OTOMATISASI] Wajib menerima campaign, tidak perlu pilih lagi
  final Donation campaign;

  const CreateFundRecordScreen({super.key, required this.campaign});

  @override
  _CreateFundRecordScreenState createState() => _CreateFundRecordScreenState();
}

class _CreateFundRecordScreenState extends State<CreateFundRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late LocalFundService _localService;
  
  String _penerima = '';
  num _uangKeluar = 0;
  num _sisaSaldo = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _localService = LocalFundService();
    _localService.init();
    // Set saldo awal berdasarkan data yang diterima
    _sisaSaldo = widget.campaign.collected;
  }

  void _onKeluarChanged(String val) {
    final parsed = num.tryParse(val.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    setState(() {
      _uangKeluar = parsed;
      _sisaSaldo = widget.campaign.collected - _uangKeluar;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      // [OTOMATISASI] Gunakan widget.campaign.id langsung
      final record = FundRecord(
        donationId: widget.campaign.id,
        programName: widget.campaign.nama,
        penerima: _penerima,
        uangKeluar: _uangKeluar,
        sisaSaldo: _sisaSaldo,
        timestamp: DateTime.now(),
      );
      
      await _localService.addRecord(record);
      
      _formKey.currentState!.reset();
      setState(() {
        _uangKeluar = 0;
        _sisaSaldo = widget.campaign.collected;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan')),
      );
      // Opsional: Langsung kembali setelah simpan agar admin lihat list
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _format(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4D5BFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Catat Pengeluaran', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Donasi (Tanpa Dropdown)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(
                    widget.campaign.nama,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Terkumpul:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      Text(_format(widget.campaign.collected), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sisa Saldo Setelah Transaksi', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                  Text(_format(_sisaSaldo), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Formulir', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Penerima / Keterangan',
                    icon: Icons.person_outline_rounded,
                    onSaved: (v) => _penerima = v!.trim(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Jumlah Uang Keluar (Rp)',
                    icon: Icons.monetization_on_outlined,
                    isNumber: true,
                    onChanged: _onKeluarChanged,
                    onSaved: (v) => _uangKeluar = num.tryParse(v!.replaceAll('.', '')) ?? 0,
                    validator: (v) => (num.tryParse(v!.replaceAll('.', '')) ?? 0) <= 0 ? 'Masukkan angka valid' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Simpan Catatan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isNumber = false,
    required Function(String?) onSaved,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: GoogleFonts.poppins(),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator ?? (v) => v!.isEmpty ? 'Wajib diisi' : null,
    );
  }
}