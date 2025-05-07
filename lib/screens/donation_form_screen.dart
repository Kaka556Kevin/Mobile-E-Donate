import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  late String _nama;
  late String _deskripsi;
  late double _targetTerkumpul;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.donation != null) {
      _nama = widget.donation!.nama;
      _deskripsi = widget.donation!.deskripsi;
      _targetTerkumpul = widget.donation!.targetTerkumpul;
    } else {
      _nama = '';
      _deskripsi = '';
      _targetTerkumpul = 0.0;
    }
  }

  Future<void> _getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Donation donation = Donation(
        id: widget.donation?.id ?? 0,
        nama: _nama,
        gambar: widget.donation?.gambar ?? '',
        deskripsi: _deskripsi,
        targetTerkumpul: _targetTerkumpul,
      );

      try {
        if (widget.donation == null) {
          await ApiService().createDonation(donation, _imageFile!);
        } else {
          await ApiService().updateDonation(donation, imageFile: _imageFile);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.donation != null ? 'Edit Donasi' : 'Tambah Donasi')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: _nama,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _nama = value!,
              ),
              TextFormField(
                initialValue: _deskripsi,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _deskripsi = value!,
              ),
              TextFormField(
                initialValue: _targetTerkumpul.toString(),
                decoration: InputDecoration(labelText: 'Target Terkumpul'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _targetTerkumpul = double.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Pilih Gambar'),
              ),
              if (_imageFile != null) Image.file(_imageFile!, height: 150),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.donation != null ? 'Update' : 'Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
