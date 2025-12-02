// lib/screens/donation_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // [PENTING] Import intl
import '../services/api_service.dart';
import '../models/donation.dart';
import '../widgets/custom_image_picker.dart';

class DonationFormScreen extends StatefulWidget {
  final Donation? donation;
  const DonationFormScreen({super.key, this.donation});

  @override
  _DonationFormScreenState createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nama;
  late String _deskripsi;
  late double _target;
  late DateTime _deadline; // [MODIFIKASI] Variabel Deadline
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nama = widget.donation?.nama ?? '';
    _deskripsi = widget.donation?.deskripsi ?? '';
    _target = widget.donation?.target ?? 0.0;
    // [MODIFIKASI] Set deadline default 30 hari jika baru, atau ambil existing
    _deadline = widget.donation?.deadline ?? DateTime.now().add(const Duration(days: 30));
  }

  // [MODIFIKASI] Picker Tanggal
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), 
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final donation = Donation(
      id: widget.donation?.id ?? 0,
      nama: _nama,
      deskripsi: _deskripsi,
      target: _target,
      gambar: widget.donation?.gambar ?? '',
      collected: widget.donation?.collected ?? 0,
      createdAt: widget.donation?.createdAt ?? DateTime.now(),
      deadline: _deadline, // [MODIFIKASI] Sertakan deadline
    );

    try {
      if (widget.donation == null) {
        await ApiService().createDonation(donation, _imageFile);
      } else {
        await ApiService().updateDonation(donation, _imageFile);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4D5BFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          widget.donation == null ? 'Buat Donasi Baru' : 'Edit Donasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Utama', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Nama Kampanye',
                      initialValue: _nama,
                      icon: Icons.campaign_rounded,
                      onSaved: (v) => _nama = v!.trim(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Deskripsi Lengkap',
                      initialValue: _deskripsi,
                      icon: Icons.description_rounded,
                      maxLines: 4,
                      onSaved: (v) => _deskripsi = v!.trim(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Target Donasi (Rp)',
                      initialValue: _target == 0 ? '' : _target.toInt().toString(),
                      icon: Icons.monetization_on_rounded,
                      isNumber: true,
                      onSaved: (v) => _target = double.tryParse(v!) ?? 0.0,
                    ),
                    const SizedBox(height: 16),

                    // [MODIFIKASI] Input Field untuk Deadline
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tenggat Waktu Donasi',
                          prefixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        child: Text(
                          DateFormat('dd MMMM yyyy', 'id_ID').format(_deadline),
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text('Media', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          if (widget.donation != null && widget.donation!.gambar.isNotEmpty && _imageFile == null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://dalitmayaan.com/storage/${widget.donation!.gambar}',
                                height: 150, width: double.infinity, fit: BoxFit.cover
                              ),
                            ),
                          const SizedBox(height: 12),
                          CustomImagePicker(onImageSelected: (file) {
                            setState(() => _imageFile = file);
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          widget.donation == null ? 'Publikasikan Donasi' : 'Simpan Perubahan',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: GoogleFonts.poppins(),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: maxLines > 1,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D5BFF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Data ini wajib diisi' : null,
      onSaved: onSaved,
    );
  }
}