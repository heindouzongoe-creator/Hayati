import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = "https://ton-backend.com/api";

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Erreur HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }
}