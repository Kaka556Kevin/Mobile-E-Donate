// lib/services/api_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/donation.dart';
import '../models/form_donasi.dart';
import '../models/kelola_donasi.dart';
import '../models/uang_donasi.dart';
import '../models/donation_trend.dart';
import '../models/fund_detail.dart';

class ApiService {
  final String baseUrl = "https://dalitmayaan.com/api";

  /// --- DashboardScreen needs this ---
  Future<List<FormDonasi>> fetchFormDonasi() async {
    final uri = Uri.parse('$baseUrl/form-donasi');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body) as List<dynamic>;
      return list
        .map((e) => FormDonasi.fromJson(e as Map<String, dynamic>))
        .toList();
    }
    throw Exception('Gagal memuat FormDonasi: ${resp.statusCode}');
  }

  /// --- DonationsScreen, HomeScreen need this ---
  Future<List<Donation>> getAllDonations() async {
    final uri = Uri.parse('$baseUrl/donations');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body) as List<dynamic>;
      return list
        .map((e) => Donation.fromJson(e as Map<String, dynamic>))
        .toList();
    }
    throw Exception('Failed to load donations: ${resp.statusCode}');
  }

  Future<Donation> createDonation(Donation donation, File? imageFile) async {
    final uri = Uri.parse('$baseUrl/donations');
    final req = http.MultipartRequest('POST', uri)
      ..fields['nama'] = donation.nama
      ..fields['deskripsi'] = donation.deskripsi
      ..fields['target_terkumpul'] = donation.target.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes(
        'gambar',
        bytes,
        filename: imageFile.path.split('/').last,
      ));
    }

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Donation.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Create failed: ${resp.statusCode}');
  }

  Future<Donation> updateDonation(Donation donation, File? imageFile) async {
    final uri = Uri.parse('$baseUrl/donations/${donation.id}');
    final req = http.MultipartRequest('POST', uri)
      ..fields['_method'] = 'PUT'
      ..fields['nama'] = donation.nama
      ..fields['deskripsi'] = donation.deskripsi
      ..fields['target_terkumpul'] = donation.target.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes(
        'gambar',
        bytes,
        filename: imageFile.path.split('/').last,
      ));
    }

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Donation.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Update failed: ${resp.statusCode}');
  }

  Future<void> deleteDonation(int id) async {
    final uri = Uri.parse('$baseUrl/donations/$id');
    final resp = await http.delete(uri);
    if (resp.statusCode != 200) {
      throw Exception('Delete failed: ${resp.statusCode}');
    }
  }

  /// --- GrafikDonasiScreen & ReportsScreen need this ---
  Future<List<KelolaDonasi>> fetchKelolaDonasi() async {
    final uri = Uri.parse('$baseUrl/kelola-donasi');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body) as List<dynamic>;
      return list
        .map((e) => KelolaDonasi.fromJson(e as Map<String, dynamic>))
        .toList();
    }
    throw Exception('Gagal memuat KelolaDonasi: ${resp.statusCode}');
  }

  Future<DonationTrend> fetchDonationTrend(String campaign) async {
    final uri = Uri.parse('$baseUrl/donasi-trend?campaign=$campaign');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return DonationTrend.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat DonationTrend: ${resp.statusCode}');
  }

  /// --- FinanceScreen needs this ---
  Future<List<UangDonasi>> fetchUangDonasi() async {
    final uri = Uri.parse('$baseUrl/uang-donasi');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body) as List<dynamic>;
      return list
        .map((e) => UangDonasi.fromJson(e as Map<String, dynamic>))
        .toList();
    }
    throw Exception('Gagal memuat UangDonasi: ${resp.statusCode}');
  }

  /// --- FundsScreen needs this ---
  Future<FundDetail> fetchFundDetail(String campaign) async {
    final uri = Uri.parse('$baseUrl/fund-detail?campaign=$campaign');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return FundDetail.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat FundDetail: ${resp.statusCode}');
  }
}
