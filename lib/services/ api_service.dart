// lib/services/api_service.dart
// Service centralisé pour tous les appels vers le backend Laravel de Herresso
// Remplace BASE_URL par l'adresse de ton serveur Laravel

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Mets ici l'URL de ton backend Laravel
  // En local avec Laragon : http://10.0.2.2:8000/api   (pour émulateur Android)
  // En production          : https://ton-domaine.com/api
  static const String BASE_URL = 'http://10.0.2.2:8000/api';

  // Token d'authentification Sanctum — mis à jour après login
  static String? _token;

  // ─────────────────────────────────────────
  // 🔧 HEADERS
  // ─────────────────────────────────────────

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  // ─────────────────────────────────────────
  //  AUTHENTIFICATION
  // ─────────────────────────────────────────

  /// POST /api/login
  /// Corps : { email, password }
  /// Retourne : { token, user }
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  /// POST /api/register
  /// Corps : { nom, prenom, email, telephone, password, password_confirmation, role }
  /// Retourne : { token, user }
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
    required String role, // 'locataire' ou 'proprietaire'
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/register'),
      headers: _headers,
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'password': password,
        'password_confirmation': password,
        'role': role,
      }),
    );
    return _handleResponse(response);
  }

  /// POST /api/logout
  /// Retourne : { message }
  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse('$BASE_URL/logout'),
      headers: _headers,
    );
    clearToken();
    return _handleResponse(response);
  }

  /// GET /api/me
  /// Retourne le profil de l'utilisateur connecté
  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/me'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // BIENS IMMOBILIERS
  // ─────────────────────────────────────────

  /// GET /api/biens
  /// Paramètres optionnels : ville, type_location, prix_max, search
  /// Retourne : { data: [Bien], total, page }
  static Future<Map<String, dynamic>> getBiens({
    String? ville,
    String? typeLocation,
    double? prixMax,
    String? search,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      if (ville != null && ville != 'Tous') 'ville': ville,
      if (typeLocation != null) 'type_location': typeLocation,
      if (prixMax != null) 'prix_max': prixMax.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse('$BASE_URL/biens').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// GET /api/biens/{id}
  /// Retourne le détail d'un bien
  static Future<Map<String, dynamic>> getBienDetail(int id) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/biens/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// POST /api/biens
  /// Corps : toutes les infos du bien
  /// Réservé aux propriétaires
  static Future<Map<String, dynamic>> publierBien({
    required String titre,
    required String description,
    required String ville,
    required String secteur,
    required String quartier,
    required double prix,
    required String typeLocation, // 'courte_duree' | 'longue_duree'
    required String typeBien,     // 'villa' | 'appartement' | 'cours_commune' | ...
    required int nombreChambres,
    required int nombreSallesDeBain,
    bool? climatisation,
    bool? wifi,
    bool? parking,
    bool? eau,
    bool? electricite,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/biens'),
      headers: _headers,
      body: jsonEncode({
        'titre': titre,
        'description': description,
        'ville': ville,
        'secteur': secteur,
        'quartier': quartier,
        'prix': prix,
        'type_location': typeLocation,
        'type_bien': typeBien,
        'nombre_chambres': nombreChambres,
        'nombre_salles_de_bain': nombreSallesDeBain,
        'climatisation': climatisation ?? false,
        'wifi': wifi ?? false,
        'parking': parking ?? false,
        'eau': eau ?? true,
        'electricite': electricite ?? true,
      }),
    );
    return _handleResponse(response);
  }

  /// DELETE /api/biens/{id}
  static Future<Map<String, dynamic>> supprimerBien(int id) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL/biens/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// GET /api/mes-biens
  /// Biens du propriétaire connecté
  static Future<Map<String, dynamic>> getMesBiens() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/mes-biens'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  //  RÉSERVATIONS
  // ─────────────────────────────────────────

  /// POST /api/reservations
  /// Corps : { bien_id, date_debut, date_fin, mode_paiement }
  static Future<Map<String, dynamic>> creerReservation({
    required int bienId,
    required String dateDebut,   // format: 'YYYY-MM-DD'
    required String dateFin,     // format: 'YYYY-MM-DD'
    required String modePaiement, // 'orange_money' | 'moov_money' | 'coris_money'
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/reservations'),
      headers: _headers,
      body: jsonEncode({
        'bien_id': bienId,
        'date_debut': dateDebut,
        'date_fin': dateFin,
        'mode_paiement': modePaiement,
      }),
    );
    return _handleResponse(response);
  }

  /// GET /api/mes-reservations
  static Future<Map<String, dynamic>> getMesReservations() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/mes-reservations'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// PATCH /api/reservations/{id}/annuler
  static Future<Map<String, dynamic>> annulerReservation(int id) async {
    final response = await http.patch(
      Uri.parse('$BASE_URL/reservations/$id/annuler'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // VISITES
  // ─────────────────────────────────────────

  /// POST /api/visites
  /// Corps : { bien_id, date_visite, heure_visite, message }
  static Future<Map<String, dynamic>> demanderVisite({
    required int bienId,
    required String dateVisite,  // format: 'YYYY-MM-DD'
    required String heureVisite, // format: 'HH:MM'
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/visites'),
      headers: _headers,
      body: jsonEncode({
        'bien_id': bienId,
        'date_visite': dateVisite,
        'heure_visite': heureVisite,
        if (message != null) 'message': message,
      }),
    );
    return _handleResponse(response);
  }

  /// GET /api/mes-visites
  static Future<Map<String, dynamic>> getMesVisites() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/mes-visites'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────

  /// GET /api/notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/notifications'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// PATCH /api/notifications/{id}/lire
  static Future<Map<String, dynamic>> marquerNotificationLue(int id) async {
    final response = await http.patch(
      Uri.parse('$BASE_URL/notifications/$id/lire'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// PATCH /api/notifications/lire-tout
  static Future<Map<String, dynamic>> marquerToutesLues() async {
    final response = await http.patch(
      Uri.parse('$BASE_URL/notifications/lire-tout'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // AVIS / NOTATION
  // ─────────────────────────────────────────

  /// POST /api/biens/{id}/avis
  /// Corps : { note, commentaire }
  static Future<Map<String, dynamic>> laisserAvis({
    required int bienId,
    required double note,       // entre 1.0 et 5.0
    required String commentaire,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/biens/$bienId/avis'),
      headers: _headers,
      body: jsonEncode({
        'note': note,
        'commentaire': commentaire,
      }),
    );
    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // PROFIL
  // ─────────────────────────────────────────

  /// PUT /api/profil
  /// Corps : champs à mettre à jour
  static Future<Map<String, dynamic>> updateProfil({
    String? nom,
    String? prenom,
    String? telephone,
  }) async {
    final response = await http.put(
      Uri.parse('$BASE_URL/profil'),
      headers: _headers,
      body: jsonEncode({
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (telephone != null) 'telephone': telephone,
      }),
    );
    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  //  GESTION DES RÉPONSES
  // ─────────────────────────────────────────

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Succès
      return {'success': true, 'data': body};
    } else if (response.statusCode == 401) {
      // Non authentifié
      clearToken();
      throw ApiException(
        message: 'Session expirée. Veuillez vous reconnecter.',
        statusCode: 401,
      );
    } else if (response.statusCode == 422) {
      // Erreurs de validation Laravel
      final errors = body['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first;
      throw ApiException(
        message: firstError is List ? firstError.first : body['message'] ?? 'Données invalides',
        statusCode: 422,
        errors: errors,
      );
    } else if (response.statusCode == 403) {
      throw ApiException(
        message: 'Accès non autorisé.',
        statusCode: 403,
      );
    } else if (response.statusCode == 404) {
      throw ApiException(
        message: 'Ressource introuvable.',
        statusCode: 404,
      );
    } else {
      throw ApiException(
        message: body['message'] ?? 'Erreur serveur.',
        statusCode: response.statusCode,
      );
    }
  }
}

// ─────────────────────────────────────────
// CLASSE D'ERREUR PERSONNALISÉE
// ─────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}