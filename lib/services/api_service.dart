import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donation.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  Future<List<Donation>> getAllDonations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/donations'));
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

  Future<Donation> createDonation(Donation donation, File? imageFile) async {
    final uri = Uri.parse('$baseUrl/api/donations');
    final request = http.MultipartRequest('POST', uri);

    // Tambahkan field hanya jika memiliki nilai
    if (donation.nama.isNotEmpty) {
      request.fields['nama'] = donation.nama;
    }
    if (donation.deskripsi.isNotEmpty) {
      request.fields['deskripsi'] = donation.deskripsi;
    }
    if (donation.targetTerkumpul > 0) {
      request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();
    }

    // Tambahkan gambar jika ada
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      final multipartImage = http.MultipartFile.fromBytes(
        'gambar',
        imageBytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartImage);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Donation.fromJson(json.decode(response.body));
    } else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(
            'Create failed: ${errorData['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Create failed with status ${response.statusCode}');
      }
    }
  }

  Future<Donation> updateDonation(Donation donation, {File? imageFile}) async {
    final uri = Uri.parse('$baseUrl/api/donations/${donation.id}');
    final request = http.MultipartRequest('POST', uri);

    // Spoof method PUT
    request.fields['_method'] = 'PUT';

    // Tambahkan field hanya jika memiliki nilai
    if (donation.nama.isNotEmpty) {
      request.fields['nama'] = donation.nama;
    }
    if (donation.deskripsi.isNotEmpty) {
      request.fields['deskripsi'] = donation.deskripsi;
    }
    if (donation.targetTerkumpul > 0) {
      request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();
    }

    // Tambahkan gambar jika ada
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      final multipartImage = http.MultipartFile.fromBytes(
        'gambar',
        imageBytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartImage);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Donation.fromJson(json.decode(response.body));
    } else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(
            'Update failed: ${errorData['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Update failed with status ${response.statusCode}');
      }
    }
  }

  Future<void> deleteDonation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/donations/$id'));
    if (response.statusCode != 200) {
      try {
        final errorData = json.decode(response.body);
        throw Exception(
            'Delete failed: ${errorData['message'] ?? 'Unknown error'}');
      } catch (e) {
        throw Exception('Delete failed with status ${response.statusCode}');
      }
    }
  }
}
