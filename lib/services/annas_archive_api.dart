import 'dart:convert';
import 'package:http/http.dart' as http;

class AnnasArchiveApi {
  static const String apiKey = '620d182c88msh7a8dedf0e4fc110p11774ejsnab3c124264e8';
  static const String apiHost = 'annas-archive-api.p.rapidapi.com';

  static Future<List<dynamic>> searchBooks(String query, {String category = 'all'}) async {
    // Reemplazar 'novelas' por 'fiction' en la categoría
    if (category == 'novelas') {
      category = 'fiction';
    }
    final url = Uri.parse(
        'https://$apiHost/search?q=$query&cat=$category&skip=0&limit=600&ext=pdf,epub,mobi,azw3&sort=mostRelevant');
    final response = await http.get(url, headers: {
      'x-rapidapi-key': apiKey,
      'x-rapidapi-host': apiHost,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['books'];
    } else {
      print('Failed to load books: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }

  static Future<List<String>> downloadBook(String md5) async {
    final url = Uri.parse('https://$apiHost/download?md5=$md5');
    final response = await http.get(url, headers: {
      'x-rapidapi-key': apiKey,
      'x-rapidapi-host': apiHost,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      print('Failed to download book: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }
}