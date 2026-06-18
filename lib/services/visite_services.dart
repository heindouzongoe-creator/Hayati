import 'dart:convert';
import 'package:http/http.dart' as http;

enum VisiteStatus { accepted, rejected, pending }

class VisiteService {
  final String baseUrl;
  final String token;

  VisiteService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Locataire : envoyer une demande de visite
  Future<Map<String, dynamic>> demanderVisite({
    required String locataireId,
    required String piedId,
    required DateTime dateVisite,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visites'),
      headers: _headers,
      body: jsonEncode({
        'locataire_id': locataireId,
        'pied_id': piedId,
        'date_visite': dateVisite.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body)['data'] as Map);
    }
    throw Exception('Erreur lors de la demande de visite');
  }

  // Locataire : récupérer ses demandes de visite
  Future<List<Map<String, dynamic>>> getMesVisites(String locataireId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/visites?locataire_id=$locataireId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    throw Exception('Erreur lors du chargement des visites');
  }

  // Propriétaire : accepter ou refuser une visite
  Future<Map<String, dynamic>> repondreVisite({
    required String visiteId,
    required VisiteStatus status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/visites/$visiteId'),
      headers: _headers,
      body: jsonEncode({'status': status.name}),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body)['data'] as Map);
    }
    throw Exception('Erreur lors de la réponse à la visite');
  }
}