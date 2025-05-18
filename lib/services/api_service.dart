// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donation.dart';

class ApiService {
  // Hanya root API, tanpa /donations
  final String baseUrl = 'https://dalitmayaan.com/api';

  /// GET  /donations
  Future<List<Donation>> fetchAllDonations() async {
    final resp = await http.get(Uri.parse('$baseUrl/donations'));
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body) as List<dynamic>;
      return list.map((e) => Donation.fromJson(e)).toList();
    }
    throw Exception('Load failed: ${resp.statusCode}');
  }

  /// POST /donations
  Future<Donation> createDonation(Donation d, File? imageFile) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/donations'))
      ..fields['nama'] = d.nama
      ..fields['deskripsi'] = d.deskripsi
      ..fields['target_terkumpul'] = d.target.toString();
    if (imageFile != null) {
      final b = await imageFile.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes('gambar', b,
        filename: imageFile.path.split('/').last));
    }
    final r = await req.send();
    final resp = await http.Response.fromStream(r);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Donation.fromJson(json.decode(resp.body));
    }
    throw Exception('Create failed: ${resp.statusCode}');
  }

  /// PUT /donations/{id}
  Future<Donation> updateDonation(Donation d, File? imageFile) async {
    final uri = Uri.parse('$baseUrl/donations/${d.id}');
    final req = http.MultipartRequest('POST', uri)
      ..fields['_method'] = 'PUT'
      ..fields['nama'] = d.nama
      ..fields['deskripsi'] = d.deskripsi
      ..fields['target_terkumpul'] = d.target.toString();
    if (imageFile != null) {
      final b = await imageFile.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes('gambar', b,
        filename: imageFile.path.split('/').last));
    }
    final r = await req.send();
    final resp = await http.Response.fromStream(r);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Donation.fromJson(json.decode(resp.body));
    }
    throw Exception('Update failed: ${resp.statusCode}');
  }

  /// DELETE /donations/{id}
  Future<void> deleteDonation(int id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/donations/$id'));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Delete failed: ${resp.statusCode}');
    }
  }
}
