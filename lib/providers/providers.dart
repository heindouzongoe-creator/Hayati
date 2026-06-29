// lib/providers/proprietaire_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/models.dart';

class ProprietaireProvider extends ChangeNotifier {
  static const String _baseUrl = 'http://VOTRE_IP:8000/api'; // ← changez ici

  bool _isLoading = false;
  String? _erreur;
  List<Bien> _mesBiens = [];

  bool get isLoading => _isLoading;
  String? get erreur => _erreur;
  List<Bien> get mesBiens => _mesBiens;

  String? _token; // token Sanctum

  void setToken(String? token) {
    _token = token;
  }

  // ─────────────────────────────────────────
  // PUBLIER UN BIEN
  // ─────────────────────────────────────────
  Future<bool> publierBien({
    required String titre,
    required String description,
    required String ville,
    required String secteur,
    String? quartier,
    required double prix,
    required String typeLocation,       // 'sejour' ou 'long_terme'
    required String typeBien,           // 'logement' ou 'local_commercial'
    required int nombreChambres,
    required int nombreSallesDeBain,
    required bool climatisation,
    required bool wifi,
    required bool parking,
    required bool eau,
    required bool electricite,
    List<File>? photos,
    List<Uint8List>? photosBytes,       // pour le web
  }) async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      // Multipart request pour envoyer les photos
      final uri = Uri.parse('$_baseUrl/biens');
      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      // Champs texte
      request.fields['titre']                  = titre;
      request.fields['description']            = description;
      request.fields['ville']                  = ville;
      request.fields['secteur']                = secteur;
      request.fields['prix']                   = prix.toString();
      request.fields['type_location']          = typeLocation;
      request.fields['type_bien']              = typeBien;
      request.fields['nombre_chambres']        = nombreChambres.toString();
      request.fields['nombre_salles_de_bain']  = nombreSallesDeBain.toString();
      request.fields['climatisation']          = climatisation ? '1' : '0';
      request.fields['wifi']                   = wifi ? '1' : '0';
      request.fields['parking']               = parking ? '1' : '0';
      request.fields['eau']                    = eau ? '1' : '0';
      request.fields['electricite']            = electricite ? '1' : '0';
      if (quartier != null) request.fields['quartier'] = quartier;

      // Photos (mobile)
      if (!kIsWeb && photos != null) {
        for (int i = 0; i < photos.length; i++) {
          final file = photos[i];
          request.files.add(await http.MultipartFile.fromPath(
            'photos[]',
            file.path,
          ));
        }
      }

      // Photos (web)
      if (kIsWeb && photosBytes != null) {
        for (int i = 0; i < photosBytes.length; i++) {
          request.files.add(http.MultipartFile.fromBytes(
            'photos[]',
            photosBytes[i],
            filename: 'photo_$i.jpg',
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Recharger la liste des biens
        await chargerMesBiens();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Gérer les erreurs de validation Laravel
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          _erreur = errors.values.first[0];
        } else {
          _erreur = data['message'] ?? 'Erreur lors de la publication';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _erreur = 'Erreur réseau : ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────
  // MES BIENS
  // ─────────────────────────────────────────
  Future<void> chargerMesBiens() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mes-biens'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _mesBiens = data.map((j) => Bien.fromJson(j)).toList();
      }
    } catch (e) {
      _erreur = 'Erreur réseau : ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // SUPPRIMER UN BIEN
  // ─────────────────────────────────────────
  Future<bool> supprimerBien(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/biens/$id'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _mesBiens.removeWhere((b) => b.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}