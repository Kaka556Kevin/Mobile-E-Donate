// lib/screens/donation_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import '../widgets/custom_image_picker.dart';

class DonationFormScreen extends StatefulWidget {
  final Donation? donation;
  const DonationFormScreen({Key? key, this.donation}) : super(key: key);

  @override
  _DonationFormScreenState createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nama;
  late String _deskripsi;
  late double _target;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nama = widget.donation?.nama ?? '';
    _deskripsi = widget.donation?.deskripsi ?? '';
    _target = widget.donation?.target ?? 0.0;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.donation == null ? 'Tambah Donasi' : 'Edit Donasi'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _nama,
                      decoration: InputDecoration(labelText: 'Nama'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _nama = v!.trim(),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      initialValue: _deskripsi,
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _deskripsi = v!.trim(),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      initialValue: _target.toString(),
                      decoration: InputDecoration(labelText: 'Target Terkumpul'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _target = double.parse(v!),
                    ),
                    SizedBox(height: 20),
                    CustomImagePicker(onImageSelected: (file) {
                      _imageFile = file;
                    }),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.donation == null ? 'Simpan' : 'Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
