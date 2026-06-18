import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'dart:io';

class ProprietaireProvider extends ChangeNotifier {
  List<Bien> _mesBiens = [];
  bool _isLoading = false;
  String? _erreur;

  List<Bien> get mesBiens => _mesBiens;
  bool get isLoading => _isLoading;
  String? get erreur => _erreur;

  
  int get totalBiens => _mesBiens.length;
  int get biensDisponibles =>
      _mesBiens.where((b) => b.statut == StatutBien.disponible).length;
  int get biensLoues =>
      _mesBiens.where((b) => b.statut == StatutBien.louer).length;
  int get biensReserves =>
      _mesBiens.where((b) => b.statut == StatutBien.reserve).length;

  // CHARGER MES BIENS

  Future<void> chargerMesBiens() async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      // API service method name adjusted: use getBiens() which returns the list of biens
      final res = await ApiService.getBiens();
      final liste = res['data']['data'] as List? ?? res['data'] as List? ?? [];
      _mesBiens = liste.map((b) => Bien.fromJson(b)).toList();
    } catch (e) {
      _erreur = e is ApiException ? e.message : 'Impossible de charger vos biens.';
      _mesBiens = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // PUBLIER UN BIEN

    Future<bool> publierBien({
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
    bool climatisation = false,
    bool wifi = false,
    bool parking = false,
    bool eau = true,
    bool electricite = true,
    List<File>? photos,
  }) async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      await ApiService.publierBien(
        titre: titre,
        description: description,
        ville: ville,
        secteur: secteur,
        quartier: quartier,
        prix: prix,
        typeLocation: typeLocation,
        typeBien: typeBien,
        nombreChambres: nombreChambres,
        nombreSallesDeBain: nombreSallesDeBain,
        climatisation: climatisation,
        wifi: wifi,
        parking: parking,
        eau: eau,
        electricite: electricite,
        photos: photos,
      );

      // Recharger la liste après publication
      await chargerMesBiens();
      return true;
    } catch (e) {
      _erreur = e is ApiException ? e.message : 'Impossible de publier ce bien.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  // MODIFIER UN BIEN
  Future<bool> modifierBien({
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
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      await ApiService.modifierBien(
        id: id,
        titre: titre,
        description: description,
        ville: ville,
        secteur: secteur,
        quartier: quartier,
        prix: prix,
        typeLocation: typeLocation,
        typeBien: typeBien,
        nombreChambres: nombreChambres,
        nombreSallesDeBain: nombreSallesDeBain,
        climatisation: climatisation,
        wifi: wifi,
        parking: parking,
        eau: eau,
        electricite: electricite,
        statut: statut,
      );
      await chargerMesBiens();
      return true;
    } catch (e) {
      _erreur = e is ApiException ? e.message : 'Impossible de modifier ce bien.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // SUPPRIMER UN BIEN
  Future<bool> supprimerBien(int id) async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      // Use the ApiService deletion method (consistent naming with other methods)
      // Adjusted to use deleteBien which is the actual method name in ApiService
      await ApiService.supprimerBien(id);
      _mesBiens.removeWhere((b) => b.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erreur = e is ApiException ? e.message : 'Impossible de supprimer ce bien.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // CHANGER LE STATUT D'UN BIEN

  Future<bool> changerStatut(int id, StatutBien nouveauStatut) async {
    final statutStr = nouveauStatut == StatutBien.disponible
        ? 'disponible'
        : nouveauStatut == StatutBien.louer
            ? 'loue'
            : 'reserve';

    return modifierBien(id: id, statut: statutStr);
  }

  // UTILITAIRES

  Bien? getBienById(int id) {
    try {
      return _mesBiens.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearErreur() {
    _erreur = null;
    notifyListeners();

  }
}