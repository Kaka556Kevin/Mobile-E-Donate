// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../widgets/custom_image_picker.dart';
// import '../services/api_service.dart';
// import '../models/donation.dart';

// class DonationFormScreen extends StatefulWidget {
//   final Donation? donation;
//   DonationFormScreen({this.donation});

//   @override
//   _DonationFormScreenState createState() => _DonationFormScreenState();
// }

// class _DonationFormScreenState extends State<DonationFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late String _nama, _deskripsi;
//   late double _target;
//   File? _imageFile;
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _nama = widget.donation?.nama ?? '';
//     _deskripsi = widget.donation?.deskripsi ?? '';
//     _target = widget.donation?.target ?? 0.0;
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();
//     setState(() => _loading = true);

//     final d = Donation(
//       id: widget.donation?.id ?? 0,
//       nama: _nama,
//       deskripsi: _deskripsi,
//       gambar: widget.donation?.gambar ?? '',
//       target: _target,
//       collected: widget.donation?.collected ?? 0,
//       createdAt: widget.donation?.createdAt ?? DateTime.now(),
//     );

//     try {
//       if (widget.donation == null) {
//         await ApiService().createDonation(d, _imageFile);
//       } else {
//         await ApiService().updateDonation(d, imageFile: _imageFile);
//       }
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext ctx) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.donation != null ? 'Edit Donasi' : 'Tambah Donasi')),
//       body: _loading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(children: [
//                   TextFormField(
//                     initialValue: _nama,
//                     decoration: InputDecoration(labelText: 'Nama', filled: true),
//                     validator: (v) => v!.isEmpty ? 'Required' : null,
//                     onSaved: (v) => _nama = v!,
//                   ),
//                   SizedBox(height: 12),
//                   TextFormField(
//                     initialValue: _deskripsi,
//                     decoration: InputDecoration(labelText: 'Deskripsi', filled: true),
//                     maxLines: 3,
//                     validator: (v) => v!.isEmpty ? 'Required' : null,
//                     onSaved: (v) => _deskripsi = v!,
//                   ),
//                   SizedBox(height: 12),
//                   TextFormField(
//                     initialValue: _target.toString(),
//                     decoration: InputDecoration(labelText: 'Target Terkumpul', filled: true),
//                     keyboardType: TextInputType.number,
//                     validator: (v) => v!.isEmpty ? 'Required' : null,
//                     onSaved: (v) => _target = double.parse(v!),
//                   ),
//                   SizedBox(height: 16),
//                   CustomImagePicker(onImageSelected: (f) => _imageFile = f),
//                   SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: ElevatedButton(
//                       onPressed: _submit,
//                       child: Text(widget.donation != null ? 'Update' : 'Simpan'),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//     );
//   }
// }

// lib/screens/donation_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_image_picker.dart';
import '../services/api_service.dart';
import '../models/donation.dart';

class DonationFormScreen extends StatefulWidget {
  final Donation? donation;
  DonationFormScreen({this.donation});

  @override
  _DonationFormScreenState createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nama, _deskripsi;
  late double _target;
  File? _imageFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nama = widget.donation?.nama ?? '';
    _deskripsi = widget.donation?.deskripsi ?? '';
    _target = widget.donation?.target ?? 0.0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    final d = Donation(
      id: widget.donation?.id ?? 0,
      nama: _nama,
      deskripsi: _deskripsi,
      gambar: widget.donation?.gambar ?? '',
      target: _target,
      collected: widget.donation?.collected ?? 0,
      createdAt: widget.donation?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.donation == null) {
        await ApiService().createDonation(d, _imageFile);
      } else {
        // ← Panggil dengan 2 positional arguments
        await ApiService().updateDonation(d, _imageFile);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.donation != null ? 'Edit Donasi' : 'Tambah Donasi')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    initialValue: _nama,
                    decoration: InputDecoration(labelText: 'Nama', filled: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _nama = v!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: _deskripsi,
                    decoration: InputDecoration(labelText: 'Deskripsi', filled: true),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _deskripsi = v!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: _target.toString(),
                    decoration: InputDecoration(labelText: 'Target Terkumpul', filled: true),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _target = double.parse(v!),
                  ),
                  SizedBox(height: 16),
                  CustomImagePicker(onImageSelected: (f) => _imageFile = f),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(widget.donation != null ? 'Update' : 'Simpan'),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }
}
