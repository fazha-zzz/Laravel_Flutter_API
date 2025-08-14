import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth/models/buku_model.dart';

class BukuService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/bukus';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<Buku>> fetchBukus() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => Buku.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data buku');
    }
  }

  static Future<Buku> showBuku(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Buku.fromJson(data['data']);
    } else {
      throw Exception('Gagal memuat detail buku');
    }
  }

  /// Tambah buku baru
  static Future<bool> createBuku({
    required String judul,
    required String penulis,
    required String penerbit,
    required int tahunTerbit,
    required int stok,
    required int kategoriId,
    required Uint8List fotoBytes,
    required String fotoName,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['judul'] = judul;
    request.fields['penulis'] = penulis;
    request.fields['penerbit'] = penerbit;
    request.fields['tahun_terbit'] = tahunTerbit.toString();
    request.fields['stok'] = stok.toString();
    request.fields['kategori_id'] = kategoriId.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        fotoBytes,
        filename: fotoName,
        contentType: MediaType('image', fotoName.split('.').last),
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();

    return response.statusCode == 201;
  }

  /// Update buku
  static Future<bool> updateBuku({
    required int id,
    String? judul,
    String? penulis,
    String? penerbit,
    int? tahunTerbit,
    int? stok,
    int? kategoriId,
    Uint8List? fotoBytes,
    String? fotoName,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$id?_method=PUT');
    final request = http.MultipartRequest('POST', uri);

    if (judul != null) request.fields['judul'] = judul;
    if (penulis != null) request.fields['penulis'] = penulis;
    if (penerbit != null) request.fields['penerbit'] = penerbit;
    if (tahunTerbit != null)
      request.fields['tahun_terbit'] = tahunTerbit.toString();
    if (stok != null) request.fields['stok'] = stok.toString();
    if (kategoriId != null)
      request.fields['kategori_id'] = kategoriId.toString();

    if (fotoBytes != null && fotoName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: fotoName,
          contentType: MediaType('image', fotoName.split('.').last),
        ),
      );
    }

    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();
    return response.statusCode == 200;
  }

  /// Hapus buku
  static Future<bool> deleteBuku(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
