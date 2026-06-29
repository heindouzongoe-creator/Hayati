import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
static const String _baseUrlMobile = 'http://10.0.2.2:8000/api';
static const String _baseUrlWeb = 'http://localhost:8000/api';

// URL automatique selon la plateforme
static String get baseUrl => kIsWeb ? _baseUrlWeb : _baseUrlMobile;
  static String? _token;

  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;
  
  static Future<void> _ajouterFichier(
    http.MultipartRequest request,
    String champ,
    File fichier, {
    Uint8List? bytes,
    String filename = 'photo.jpg',
  }) async {
    if (kIsWeb) {
      if (bytes == null) {
        throw ApiException(
            message: 'Photo manquante (bytes requis sur le web)', statusCode: 0);
      }
      request.files
          .add(http.MultipartFile.fromBytes(champ, bytes, filename: filename));
    } else {
      request.files
          .add(await http.MultipartFile.fromPath(champ, fichier.path));
    }
  }

  
  // AUTHENTIFICATION
  
  static Future<Map<String, dynamic>> login({
    required String identifiant,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'identifiant': identifiant, 'password': password}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    required String password,
    required String role,
    required String cnibNumero,
    File? cnibPhoto,
    File? selfiePhoto,
    Uint8List? cnibPhotoBytes,
    Uint8List? selfiePhotoBytes,
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);
    request.fields['nom'] = nom;
    request.fields['prenom'] = prenom;
    if (email != null && email.isNotEmpty) request.fields['email'] = email;
    if (telephone != null && telephone.isNotEmpty) request.fields['telephone'] = telephone;
    request.fields['password'] = password;
    request.fields['role'] = role;
    if (cnibNumero.isNotEmpty) request.fields['cnib_numero'] = cnibNumero;

    // selfie_photo 
    if (selfiePhotoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'selfie_photo', selfiePhotoBytes, filename: 'selfie.jpg',
      ));
    } else if (selfiePhoto != null && selfiePhoto.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'selfie_photo', selfiePhoto.path,
      ));
    }

    // cnib_photo : optionnelle
    if (cnibPhotoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'cnib_photo', cnibPhotoBytes, filename: 'cnib.jpg',
      ));
    } else if (cnibPhoto != null && cnibPhoto.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'cnib_photo', cnibPhoto.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {..._headers, 'Content-Type': 'application/json'},
    );
    clearToken();
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response =
        await http.get(Uri.parse('$baseUrl/me'), headers: _headers);
    return _handleResponse(response);
  }

  
  // BIENS
  
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
    final uri =
        Uri.parse('$baseUrl/biens').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> modifierBien({
    required int id,
    String? titre,
    String? description,
    String? ville,
    String? secteur,
    String? quartier,
    double? prix,
    String? typeLocation,
    String? typeBien,
    int? nombreChambres,
    int? nombreSallesDeBain,
    bool? climatisation,
    bool? wifi,
    bool? parking,
    bool? eau,
    bool? electricite,
    String? statut, 
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/biens/$id'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        if (titre != null) 'titre': titre,
        if (description != null) 'description': description,
        if (ville != null) 'ville': ville,
        if (secteur != null) 'secteur': secteur,
        if (quartier != null) 'quartier': quartier,
        if (prix != null) 'prix': prix,
        if (typeLocation != null) 'type_location': typeLocation,
        if (typeBien != null) 'type_bien': typeBien,
        if (nombreChambres != null) 'nombre_chambres': nombreChambres,
        if (nombreSallesDeBain != null)
          'nombre_salles_de_bain': nombreSallesDeBain,
        if (climatisation != null) 'climatisation': climatisation,
        if (wifi != null) 'wifi': wifi,
        if (parking != null) 'parking': parking,
        if (eau != null) 'eau': eau,
        if (electricite != null) 'electricite': electricite,
        if (statut != null) 'statut': statut, // ← ajouté
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> publierBien({
    required String titre,
    required String description,
    required String ville,
    required String secteur,
    required String quartier,
    required double prix,
    required String typeLocation,
    required String typeBien,
    required int nombreChambres,
    required int nombreSallesDeBain,
    bool? climatisation,
    bool? wifi,
    bool? parking,
    bool? eau,
    bool? electricite,
    List<File>? photos,
    List<Uint8List>? photosBytes,
  }) async {
    final uri = Uri.parse('$baseUrl/biens');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);
    request.fields['titre'] = titre;
    request.fields['description'] = description;
    request.fields['ville'] = ville;
    request.fields['secteur'] = secteur;
    request.fields['quartier'] = quartier;
    request.fields['prix'] = prix.toString();
    request.fields['type_location'] = typeLocation;
    request.fields['type_bien'] = typeBien;
    request.fields['nombre_chambres'] = nombreChambres.toString();
    request.fields['nombre_salles_de_bain'] = nombreSallesDeBain.toString();
    request.fields['climatisation'] = (climatisation ?? false).toString();
    request.fields['wifi'] = (wifi ?? false).toString();
    request.fields['parking'] = (parking ?? false).toString();
    request.fields['eau'] = (eau ?? true).toString();
    request.fields['electricite'] = (electricite ?? true).toString();

    if (photos != null) {
      for (var i = 0; i < photos.length; i++) {
        final bytes =
            (photosBytes != null && i < photosBytes.length) ? photosBytes[i] : null;
        await _ajouterFichier(request, 'photos[]', photos[i],
            bytes: bytes, filename: 'photo_$i.jpg');
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> supprimerBien(int id) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/biens/$id'),
        headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMesBiens() async {
    final response = await http.get(
        Uri.parse('$baseUrl/mes-biens'),
        headers: _headers);
    return _handleResponse(response);
  }


  // CHAMBRES

static Future<Map<String, dynamic>> getChambres(int bienId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/biens/$bienId/chambres'),
    headers: _headers,
  );
  return _handleResponse(response);
}

static Future<Map<String, dynamic>> ajouterChambre({
  required int bienId,
  required String type,
  required String nom,
  required double prix,
  int capacite = 1,
  bool petitDejeuner = false,
  bool dejeuner = false,
  bool diner = false,
  int nombreDisponible = 1,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/biens/$bienId/chambres'),
    headers: {..._headers, 'Content-Type': 'application/json'},
    body: jsonEncode({
      'type': type,
      'nom': nom,
      'prix': prix,
      'capacite': capacite,
      'petit_dejeuner': petitDejeuner,
      'dejeuner': dejeuner,
      'diner': diner,
      'nombre_disponible': nombreDisponible,
    }),
  );
  return _handleResponse(response);
}

static Future<Map<String, dynamic>> modifierChambre({
  required int id,
  String? type,
  String? nom,
  double? prix,
  int? capacite,
  bool? petitDejeuner,
  bool? dejeuner,
  bool? diner,
  int? nombreDisponible,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/chambres/$id'),
    headers: {..._headers, 'Content-Type': 'application/json'},
    body: jsonEncode({
      if (type != null) 'type': type,
      if (nom != null) 'nom': nom,
      if (prix != null) 'prix': prix,
      if (capacite != null) 'capacite': capacite,
      if (petitDejeuner != null) 'petit_dejeuner': petitDejeuner,
      if (dejeuner != null) 'dejeuner': dejeuner,
      if (diner != null) 'diner': diner,
      if (nombreDisponible != null) 'nombre_disponible': nombreDisponible,
    }),
  );
  return _handleResponse(response);
}

static Future<Map<String, dynamic>> supprimerChambre(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/chambres/$id'),
    headers: _headers,
  );
  return _handleResponse(response);
}

  
  // RÉSERVATIONS
  
  static Future<Map<String, dynamic>> creerReservation({
    required int bienId,
    required String dateDebut,
    required String dateFin,
    required String modePaiement,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'bien_id': bienId,
        'date_debut': dateDebut,
        'date_fin': dateFin,
        'mode_paiement': modePaiement,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMesReservations() async {
    final response = await http.get(
        Uri.parse('$baseUrl/mes-reservations'),
        headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> annulerReservation(int id) async {
    final response = await http.patch(
        Uri.parse('$baseUrl/reservations/$id/annuler'),
        headers: _headers);
    return _handleResponse(response);
  }

  
  // VISITES
  
  static Future<Map<String, dynamic>> demanderVisite({
    required int bienId,
    required String dateVisite,
    required String heureVisite,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visites'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'bien_id': bienId,
        'date_visite': dateVisite,
        'heure_visite': heureVisite,
        if (message != null) 'message': message,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMesVisites() async {
    final response = await http.get(
        Uri.parse('$baseUrl/mes-visites'),
        headers: _headers);
    return _handleResponse(response);
  }

  
  // NOTIFICATIONS
  
  static Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> marquerNotificationLue(int id) async {
    final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id/lire'),
        headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> marquerToutesLues() async {
    final response = await http.patch(
        Uri.parse('$baseUrl/notifications/lire-tout'),
        headers: _headers);
    return _handleResponse(response);
  }

  
  // AVIS
  
  static Future<Map<String, dynamic>> laisserAvis({
    required int bienId,
    required double note,
    required String commentaire,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/biens/$bienId/avis'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'note': note, 'commentaire': commentaire}),
    );
    return _handleResponse(response);
  }

  
  // PROFIL
  
  static Future<Map<String, dynamic>> updateProfil({
    String? nom,
    String? prenom,
    String? telephone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profil'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (telephone != null) 'telephone': telephone,
      }),
    );
    return _handleResponse(response);
  }

  static Future<void> signalerBien({
    required int bienId,
    required String motif,
    required String detail,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/biens/$bienId/signaler'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'motif': motif, 'detail': detail}),
    );
  }

  static Future<void> noterBailleur({
    required int proprietaireId,
    required int note,
    required String commentaire,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/users/$proprietaireId/avis'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'note': note, 'commentaire': commentaire}),
    );
  }

  static Future<Map<String, dynamic>> saveFcmToken(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/token'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'fcm_token': token}),
    );
    return _handleResponse(response);
  }

  
  // GESTION DES RÉPONSES

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': body};
    } else if (response.statusCode == 401) {
      clearToken();
      throw ApiException(
          message: 'Session expirée. Veuillez vous reconnecter.',
          statusCode: 401);
    } else if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first;
      throw ApiException(
        message: firstError is List
            ? firstError.first
            : body['message'] ?? 'Données invalides',
        statusCode: 422,
        errors: errors,
      );
    } else if (response.statusCode == 403) {
      throw ApiException(message: 'Accès non autorisé.', statusCode: 403);
    } else if (response.statusCode == 404) {
      throw ApiException(
          message: 'Ressource introuvable.', statusCode: 404);
    } else {
      throw ApiException(
          message: body['message'] ?? 'Erreur serveur.',
          statusCode: response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException(
      {required this.message, required this.statusCode, this.errors});

  @override
  String toString() => 'ApiException($statusCode): $message';
}