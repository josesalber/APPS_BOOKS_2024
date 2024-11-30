import 'dart:convert';
import 'package:http/http.dart' as http;

class FortniteApi {
  static const String apiUrl = 'https://fortnite-api.com/v2/cosmetics/br';

  static Future<List<Map<String, String>>> fetchCharacterImages() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['data'];
      final List<Map<String, String>> images = items
          .where((item) =>
              item['type']['value'] == 'outfit' &&
              item['images'] != null &&
              item['images']['icon'] != null &&
              ((item['series'] != null &&
                  (item['series']['value'] == 'MarvelSeries' ||
                   item['series']['value'] == 'Gaming Legends Series' ||
                   item['series']['value'] == 'Dragon Ball'))))
          .map<Map<String, String>>((item) => {
                'id': item['id'],
                'icon': item['images']['icon'],
              })
          .toList();
      return images;
    } else {
      throw Exception('Failed to load character images');
    }
  }

  static String getImageUrl(String profileImageId) {
    return 'https://fortnite-api.com/images/cosmetics/br/${profileImageId.toLowerCase()}/icon.png';
  }
}