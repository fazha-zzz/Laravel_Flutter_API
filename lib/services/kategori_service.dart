import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kategori_model.dart';

class KategoriService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Function baru untuk list kategoris yang mengembalikan Kategori model
  static Future<KategoriModel> listKategoris() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/kategoris"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return KategoriModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception("Token tidak valid atau expired");
      } else {
        throw Exception(
          "HTTP Error: ${response.statusCode} - ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      throw Exception("Gagal memuat kategori: $e");
    }
  }

  // Perbaiki return type menjadi List<Datum>
  static Future<List<DataKategori>> fetchKategoris() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/kategoris"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Cek apakah response sukses
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'];
          // Return List<Datum> bukan List<Kategori>
          return dataList.map((json) => DataKategori.fromJson(json)).toList();
        } else {
          throw Exception(
            jsonData['message'] ?? "Data kategori tidak ditemukan",
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception("Token tidak valid atau expired");
      } else {
        throw Exception(
          "HTTP Error: ${response.statusCode} - ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      throw Exception("Gagal memuat kategori: $e");
    }
  }

  static Future<DataKategori?> fetchKategoriById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/kategoris/$id"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return DataKategori.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? "Kategori tidak ditemukan");
        }
      } else if (response.statusCode == 401) {
        throw Exception("Token tidak valid atau expired");
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memuat kategori: $e");
    }
  }



  static Future<bool> createKategori(String nama) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/kategoris"),
        headers: headers,
        body: json.encode({'nama': nama}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else if (response.statusCode == 401) {
        throw Exception("Token tidak valid atau expired");
      }
      return false;
    } catch (e) {
      if (e.toString().contains('Token tidak valid')) {
        throw e; // Re-throw authentication errors
      }
      return false;
    }
  }

  static Future<bool> updateKategori(int id, String nama) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/kategoris/$id"),
        headers: headers,
        body: json.encode({'nama': nama}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else if (response.statusCode == 401) {
        throw Exception("Token tidak valid atau expired");
      }
      return false;
    } catch (e) {
      if (e.toString().contains('Token tidak valid')) {
        throw e; // Re-throw authentication errors
      }
      return false;
    }
  }
  

  static Future<bool> deleteKategori(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl/kategoris/$id"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else if (response.statusCode == 401) {
        throw Exception("Token tidak valid atau expired");
      }
      return false;
    } catch (e) {
      if (e.toString().contains('Token tidak valid')) {
        throw e; // Re-throw authentication errors
      }
      return false;
    }
  }

  // Method tambahan untuk handle logout ketika token expired
  static Future<void> handleTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Anda bisa menambahkan navigasi ke login screen di sini
  }
}
