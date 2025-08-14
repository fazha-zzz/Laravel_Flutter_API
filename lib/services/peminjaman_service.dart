import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/peminjaman_model.dart';

class PeminjamanService {
  static const String baseUrl =
      'http://127.0.0.1:8000/api'; // Change to your API URL

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  }

  // GET all peminjaman
  Future<List<PeminjamanModel>> getAllPeminjaman() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/peminjamans'),
        headers: headers,
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];

      return data.map((item) => PeminjamanModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch peminjaman: $e');
    }
  }

  // GET peminjaman by ID
  Future<PeminjamanModel> getPeminjamanById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/peminjamans/$id'),
        headers: headers,
      );

      final responseData = _handleResponse(response);
      return PeminjamanModel.fromJson(responseData['data']);
    } catch (e) {
      throw Exception('Failed to fetch peminjaman: $e');
    }
  }

  // POST create peminjaman
  Future<PeminjamanModel> createPeminjaman(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/peminjamans'),
        headers: headers,
        body: json.encode(data),
      );

      final responseData = _handleResponse(response);
      return PeminjamanModel.fromJson(responseData['data']);
    } catch (e) {
      throw Exception('Failed to create peminjaman: $e');
    }
  }

  // PUT update peminjaman
  Future<PeminjamanModel> updatePeminjaman(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/peminjamans/$id'),
        headers: headers,
        body: json.encode(data),
      );

      final responseData = _handleResponse(response);
      return PeminjamanModel.fromJson(responseData['data']);
    } catch (e) {
      throw Exception('Failed to update peminjaman: $e');
    }
  }

  // DELETE peminjaman
  Future<bool> deletePeminjaman(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/peminjamans/$id'),
        headers: headers,
      );

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Failed to delete peminjaman: $e');
    }
  }
}
