import 'dart:convert';
import 'package:http/http.dart' as http;

enum ReservationStatus { pending, approved, rejected }

class ReservationRequest {
  final String id;
  final String locataireId;
  final String offreLocationId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? message;
  final ReservationStatus status;

  ReservationRequest({
    required this.id,
    required this.locataireId,
    required this.offreLocationId,
    required this.dateDebut,
    required this.dateFin,
    this.message,
    required this.status,
  });

  factory ReservationRequest.fromJson(Map<String, dynamic> json) {
    return ReservationRequest(
      id: json['id']?.toString() ?? '',
      locataireId: json['locataire_id']?.toString() ?? '',
      offreLocationId: json['offre_location_id']?.toString() ?? '',
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
      message: json['message'] as String?,
      status: _statusFromString(json['status'] as String? ?? 'pending'),
    );
  }

  static ReservationStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return ReservationStatus.approved;
      case 'rejected':
      case 'refused':
        return ReservationStatus.rejected;
      default:
        return ReservationStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locataire_id': locataireId,
      'offre_location_id': offreLocationId,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'message': message,
      'status': status.name,
    };
  }
}

class ReservationService {
  final String baseUrl;
  final String token;

  ReservationService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Locataire : faire une demande de réservation
  Future<ReservationRequest> demanderReservation({
    required String locataireId,
    required String offreLocationId,
    required DateTime dateDebut,
    required DateTime dateFin,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: _headers,
      body: jsonEncode({
        'locataire_id': locataireId,
        'offre_location_id': offreLocationId,
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      return ReservationRequest.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Erreur lors de la demande de réservation');
  }

  // Locataire : récupérer ses réservations
  Future<List<ReservationRequest>> getMesReservations(String locataireId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations?locataire_id=$locataireId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => ReservationRequest.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du chargement des réservations');
  }

  // Propriétaire : récupérer les réservations de ses offres
  Future<List<ReservationRequest>> getReservationsProprietaire(String proprietaireId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations?proprietaire_id=$proprietaireId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => ReservationRequest.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du chargement des réservations');
  }

  // Propriétaire : accepter ou refuser une réservation
  Future<ReservationRequest> repondreReservation({
    required String reservationId,
    required ReservationStatus status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reservations/$reservationId'),
      headers: _headers,
      body: jsonEncode({'status': status.name}),
    );

    if (response.statusCode == 200) {
      return ReservationRequest.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Erreur lors de la réponse à la réservation');
  }
}