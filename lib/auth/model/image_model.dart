import 'dart:convert';
import 'package:http/http.dart';

class ImageModel {
  const ImageModel({
    required this.id,
    required this.url,
    required this.rating,
    this.artistName,
    this.sourceUrl,
  });

  factory ImageModel.fromJson(final dynamic json) => ImageModel(
        id: json['id'] != null ? json['id'] as int : 0,
        url: json['url'] != null ? json['url'] as String : '',
        rating: json['rating'] != null ? json['rating'] as String : 'unknown',
        artistName: json['artist_name'] as String?,
        sourceUrl: json['source_url'] as String?,
      );

  static const String _baseUrl = 'https://api.nekosapi.com/v4/images/random';

  static Future<String?> fetchRandomImage() async {
    final Response response = await get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body) as List<dynamic>;
      return jsonData.map(ImageModel.fromJson).toList().first.url;
    } else {
      return '';
    }
  }

  final int? id;
  final String? url;
  final String? rating;

  final String? artistName;
  final String? sourceUrl;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
      };
}
