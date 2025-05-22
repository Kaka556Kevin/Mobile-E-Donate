// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../models/donation.dart';
import '../models/form_donasi.dart';

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

  /// GET /donations/{id}
  Future<Donation> fetchDonation(int id) async {
    final resp = await http.get(Uri.parse('$base64Url/donations/$id'));
    if (resp.statusCode == 200) {
      return Donation.fromJson(json.decode(resp.body));
    }
    throw Exception('Load failed: ${resp.statusCode}');
  }

  /// GET /donations/report
  Future<List<FormDonasi>> fetchReport(String campaign) async {
    final resp = await http.get(Uri.parse('$base64Encode(bytes)/donations/report?campaign=$campaign'));
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body) as List<dynamic>;
      return list.map((e) => FormDonasi.fromJson(e)).toList();
    }
    throw Exception('Load failed: ${resp.statusCode}');
  }

  /// Launch URL for downloading report
Future<void> downloadReport(String campaign) async {
    final url = Uri.parse('https://dalitmayaan.com/api/donations/report?campaign=$campaign');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

