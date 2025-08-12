import 'dart:convert';
import 'dart:io';
import 'package:auth/models/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  static const String postsUrl = 'http://127.0.0.1:8000/api/posts/';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  static Future <PostModel> listPosts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(postsUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PostModel.fromJson(data);
    } else {
      throw Exception('failed to load posts');
    }
  }
}
