// lib/services/donation_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donation.dart';

class DonationService {
  final String apiUrl;

  DonationService({String? base}) : apiUrl = base ?? 'https://dalitmayaan.com/api/donations';

  /// Fetches the full list of donations from the API.
  Future<List<Donation>> fetchDonations() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> list;

      // Handle both plain list and wrapped { data: [...] }
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        list = decoded['data'];
      } else {
        throw Exception('Unrecognized response format');
      }

      return list
          .map((e) => Donation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Load failed: ${response.statusCode}');
  }

  /// Calculates the total collected amount across all donations.
  Future<double> fetchTotalCollected() async {
    final donations = await fetchDonations();
    double sum = 0.0;
    for (var d in donations) {
      sum += d.collected;
    }
    return sum;
  }
}
