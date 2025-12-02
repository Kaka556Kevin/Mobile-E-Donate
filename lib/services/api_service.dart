// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl untuk format tanggal
import '../models/donation.dart';
import '../models/form_donasi.dart';
import '../models/uang_donasi.dart';

class ApiService {
  final String baseUrl = 'https://dalitmayaan.com/api';

  // ... (fetchAllDonations & fetchFormDonasi tetap sama) ...
  Future<List<Donation>> fetchAllDonations() async {
    final resp = await http.get(Uri.parse('$baseUrl/donations'));
    if (resp.statusCode == 200) {
      final decoded = json.decode(resp.body);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        list = decoded['data'];
      } else {
        throw Exception('Format response tidak dikenali');
      }
      return list.map((e) => Donation.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Load failed: ${resp.statusCode}');
  }

  Future<List<FormDonasi>> fetchFormDonasi() async {
    final resp = await http.get(Uri.parse('$baseUrl/form-donasi'));
    if (resp.statusCode == 200) {
      final decoded = json.decode(resp.body) as Map<String, dynamic>;
      final dataList = decoded['data'] as List<dynamic>;
      return dataList.map((e) => FormDonasi.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Load FormDonasi failed: ${resp.statusCode}');
  }

  /// POST /donations
  Future<Donation> createDonation(Donation d, File? imageFile) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/donations'))
      ..fields['nama'] = d.nama
      ..fields['deskripsi'] = d.deskripsi
      ..fields['target_terkumpul'] = d.target.toString();
    
    // [MODIFIKASI]: Kirim tanggal ke backend
    if (d.deadline != null) {
      req.fields['tenggat_waktu_donasi'] = DateFormat('yyyy-MM-dd').format(d.deadline!);
    }

    if (imageFile != null) {
      final b = await imageFile.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes(
        'gambar', b,
        filename: imageFile.path.split('/').last));
    }
    final r = await req.send();
    final resp = await http.Response.fromStream(r);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Donation.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Create failed: ${resp.statusCode} ${resp.body}');
  }

  /// PUT /donations/{id}
  Future<Donation> updateDonation(Donation d, File? imageFile) async {
    final uri = Uri.parse('$baseUrl/donations/${d.id}');
    final req = http.MultipartRequest('POST', uri)
      ..fields['_method'] = 'PUT'
      ..fields['nama'] = d.nama
      ..fields['deskripsi'] = d.deskripsi
      ..fields['target_terkumpul'] = d.target.toString();

    // [MODIFIKASI]: Kirim tanggal ke backend
    if (d.deadline != null) {
      req.fields['tenggat_waktu_donasi'] = DateFormat('yyyy-MM-dd').format(d.deadline!);
    }

    if (imageFile != null) {
      final b = await imageFile.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes(
        'gambar', b,
        filename: imageFile.path.split('/').last));
    }
    final r = await req.send();
    final resp = await http.Response.fromStream(r);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Donation.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Update failed: ${resp.statusCode} ${resp.body}');
  }

  // ... (deleteDonation, fetchAllUangDonasi, createUangDonasi tetap sama) ...
  Future<void> deleteDonation(int id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/donations/$id'));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Delete failed: ${resp.statusCode}');
    }
  }

  Future<List<UangDonasi>> fetchAllUangDonasi() async {
    final response = await http.get(Uri.parse('$baseUrl/donations'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => UangDonasi.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load uang donasi records');
    }
  }

  Future<UangDonasi> createUangDonasi(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/uang-donasi'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (response.statusCode == 201) {
      return UangDonasi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create uang donasi');
    }
  }
}