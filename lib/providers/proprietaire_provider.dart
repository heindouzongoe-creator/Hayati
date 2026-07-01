// lib/providers/proprietaire_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ProprietaireProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _erreur;
  List<Bien> _mesBiens = [];

  bool get isLoading => _isLoading;
  String? get erreur => _erreur;
  List<Bien> get mesBiens => _mesBiens;

  // PUBLIER UN BIEN
 
  Future<bool> publierBien({
    required String titre,
    required String description,
    required String ville,
    required String secteur,
    String? quartier,
    required double prix,
    required String typeLocation,
    required String typeBien,
    required int nombreChambres,
    required int nombreSallesDeBain,
    required bool climatisation,
    required bool wifi,
    required bool parking,
    required bool eau,
    required bool electricite,
    List<File>? photos,
    List<Uint8List>? photosBytes,
  }) 
  async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      await ApiService.publierBien(
        titre:               titre,
        description:         description,
        ville:               ville,
        secteur:             secteur,
        quartier:            quartier ?? '',
        prix:                prix,
        typeLocation:        typeLocation,
        typeBien:            typeBien,
        nombreChambres:      nombreChambres,
        nombreSallesDeBain:  nombreSallesDeBain,
        climatisation:       climatisation,
        wifi:                wifi,
        parking:             parking,
        eau:                 eau,
        electricite:         electricite,
        photos:              photos,
        photosBytes:         photosBytes,
      );

      // Recharger la liste après publication
      await chargerMesBiens();

      _isLoading = false;
      notifyListeners();
      return true;

    } on ApiException catch (e) {
      _erreur = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('ERREUR PUBLIER: $e');
      _erreur = 'Erreur de connexion au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // MES BIENS
  Future<void> chargerMesBiens() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.getMesBiens();
      final List data = result['data'];
      _mesBiens = data.map((j) => Bien.fromJson(j)).toList();
    } on ApiException catch (e) {
      _erreur = e.message;
    } catch (e) {
      _erreur = 'Erreur de connexion au serveur';
    }

    _isLoading = false;
    notifyListeners();
  }
  // SUPPRIMER UN BIEN
  Future<bool> supprimerBien(int id) async {
    try {
      await ApiService.supprimerBien(id);
      _mesBiens.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _erreur = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      return false;
    }
  }
  // SUPPRIMER UN BIEN
  Future<bool> modifierBien(int id) async {
    try {
      await ApiService.modifierBien(id: id);
      _mesBiens.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _erreur = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      return false;
    }
    
  }

  void clearErreur() {
    _erreur = null;
    notifyListeners();
  }
}