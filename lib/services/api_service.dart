// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/donation.dart';

// class ApiService {
//   final String baseUrl = "http://10.0.2.2:8000";


//   Future<List<Donation>> getAllDonations() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/api/donations'));
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.map((item) => Donation.fromJson(item)).toList();
//       } else {
//         throw Exception('Failed to load donations: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<Donation> createDonation(Donation donation, File? imageFile) async {
//     final uri = Uri.parse('$baseUrl/api/donations');
//     final request = http.MultipartRequest('POST', uri);

//     // Tambahkan field hanya jika memiliki nilai
//     if (donation.nama.isNotEmpty) {
//       request.fields['nama'] = donation.nama;
//     }
//     if (donation.deskripsi.isNotEmpty) {
//       request.fields['deskripsi'] = donation.deskripsi;
//     }
//     if (donation.targetTerkumpul > 0) {
//       request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();
//     }

//     // Tambahkan gambar jika ada
//     if (imageFile != null) {
//       final imageBytes = await imageFile.readAsBytes();
//       final multipartImage = http.MultipartFile.fromBytes(
//         'gambar',
//         imageBytes,
//         filename: imageFile.path.split('/').last,
//       );
//       request.files.add(multipartImage);
//     }

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return Donation.fromJson(json.decode(response.body));
//     } else {
//       try {
//         final errorData = json.decode(response.body);
//         throw Exception(
//             'Create failed: ${errorData['message'] ?? 'Unknown error'}');
//       } catch (e) {
//         throw Exception('Create failed with status ${response.statusCode}');
//       }
//     }
//   }

//   Future<Donation> updateDonation(Donation donation, {File? imageFile}) async {
//     final uri = Uri.parse('$baseUrl/api/donations/${donation.id}');
//     final request = http.MultipartRequest('POST', uri);

//     // Spoof method PUT
//     request.fields['_method'] = 'PUT';

//     // Tambahkan field hanya jika memiliki nilai
//     if (donation.nama.isNotEmpty) {
//       request.fields['nama'] = donation.nama;
//     }
//     if (donation.deskripsi.isNotEmpty) {
//       request.fields['deskripsi'] = donation.deskripsi;
//     }
//     if (donation.targetTerkumpul > 0) {
//       request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();
//     }

//     // Tambahkan gambar jika ada
//     if (imageFile != null) {
//       final imageBytes = await imageFile.readAsBytes();
//       final multipartImage = http.MultipartFile.fromBytes(
//         'gambar',
//         imageBytes,
//         filename: imageFile.path.split('/').last,
//       );
//       request.files.add(multipartImage);
//     }

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return Donation.fromJson(json.decode(response.body));
//     } else {
//       try {
//         final errorData = json.decode(response.body);
//         throw Exception(
//             'Update failed: ${errorData['message'] ?? 'Unknown error'}');
//       } catch (e) {
//         throw Exception('Update failed with status ${response.statusCode}');
//       }
//     }
//   }

//   Future<void> deleteDonation(int id) async {
//     final response = await http.delete(Uri.parse('$baseUrl/api/donations/$id'));
//     if (response.statusCode != 200) {
//       try {
//         final errorData = json.decode(response.body);
//         throw Exception(
//             'Delete failed: ${errorData['message'] ?? 'Unknown error'}');
//       } catch (e) {
//         throw Exception('Delete failed with status ${response.statusCode}');
//       }
//     }
//   }
// }

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
  final String baseUrl = "http://10.0.2.2:8000/api";

  /// Mengambil data FormDonasi
  Future<List<FormDonasi>> fetchFormDonasi() async {
    final uri = Uri.parse('$baseUrl/form-donasi');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((item) => FormDonasi.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Gagal memuat FormDonasi: ${response.statusCode}');
  }

  /// Mengambil semua Donation
  Future<List<Donation>> getAllDonations() async {
    try {
      final uri = Uri.parse('$baseUrl/donations');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Donation.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load donations: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Membuat Donation baru dengan gambar
  Future<Donation> createDonation(Donation donation, File? imageFile) async {
    final uri = Uri.parse('$baseUrl/donations');
    final request = http.MultipartRequest('POST', uri);

    if (donation.nama.isNotEmpty) request.fields['nama'] = donation.nama;
    if (donation.deskripsi.isNotEmpty) request.fields['deskripsi'] = donation.deskripsi;
    if (donation.targetTerkumpul > 0) request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('gambar', bytes, filename: imageFile.path.split('/').last),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Donation.fromJson(json.decode(response.body));
    }
    throw Exception('Create failed: ${response.statusCode}');
  }

  /// Memperbarui Donation (PUT via spoof)
  Future<Donation> updateDonation(Donation donation, {File? imageFile}) async {
    final uri = Uri.parse('$baseUrl/donations/${donation.id}');
    final request = http.MultipartRequest('POST', uri)..fields['_method'] = 'PUT';

    if (donation.nama.isNotEmpty) request.fields['nama'] = donation.nama;
    if (donation.deskripsi.isNotEmpty) request.fields['deskripsi'] = donation.deskripsi;
    if (donation.targetTerkumpul > 0) request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('gambar', bytes, filename: imageFile.path.split('/').last),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Donation.fromJson(json.decode(response.body));
    }
    throw Exception('Update failed: ${response.statusCode}');
  }

  /// Menghapus Donation
  Future<void> deleteDonation(int id) async {
    final uri = Uri.parse('$baseUrl/donations/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Delete failed: ${response.statusCode}');
    }
  }

  /// Mengambil data KelolaDonasi untuk grafik
  Future<List<KelolaDonasi>> fetchKelolaDonasi() async {
    final uri = Uri.parse('$baseUrl/kelola-donasi');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(response.body);
      return list.map((item) => KelolaDonasi.fromJson(item)).toList();
    }
    throw Exception('Gagal memuat KelolaDonasi: ${response.statusCode}');
  }

  /// Mengambil data UangDonasi
  Future<List<UangDonasi>> fetchUangDonasi() async {
    final uri = Uri.parse('$baseUrl/uang-donasi');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(response.body);
      return list.map((item) => UangDonasi.fromJson(item)).toList();
    }
    throw Exception('Gagal memuat UangDonasi: ${response.statusCode}');
  }

  /// Mengambil DonationTrend untuk laporan
  Future<DonationTrend> fetchDonationTrend(String campaign) async {
    final uri = Uri.parse('$baseUrl/donasi-trend?campaign=$campaign');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return DonationTrend.fromJson(json.decode(response.body));
    }
    throw Exception('Gagal memuat DonationTrend: ${response.statusCode}');
  }

  /// Mengambil FundDetail untuk UangDonasi
  Future<FundDetail> fetchFundDetail(String campaign) async {
    final uri = Uri.parse('$baseUrl/fund-detail?campaign=$campaign');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return FundDetail.fromJson(json.decode(response.body));
    }
    throw Exception('Gagal memuat FundDetail: ${response.statusCode}');
  }

  /// Download report (placeholder)
  Future<void> downloadReport(String campaign) async {
    // TODO: implement download
  }
}
