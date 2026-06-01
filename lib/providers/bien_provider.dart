// lib/providers/bien_provider.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class BienProvider extends ChangeNotifier {
  List<Bien> _biens = [];
  List<Bien> _biensFiltres = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _villeFiltre = 'Tous';
  TypeLocation? _typeLocationFiltre;
  double? _prixMax;

  List<Bien> get biens => _biensFiltres;
  List<Bien> get tousLesBiens => _biens;
  bool get isLoading => _isLoading;

  Future<void> chargerBiens() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.getBiens(
        ville: _villeFiltre != 'Tous' ? _villeFiltre : null,
        typeLocation: _typeLocationFiltre == TypeLocation.courtTerme
            ? 'courte_duree'
            : _typeLocationFiltre == TypeLocation.longTerme
                ? 'longue_duree'
                : null,
        prixMax: _prixMax,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final liste = res['data']['data'] as List;
      _biens = liste.map((b) => Bien.fromJson(b)).toList();
    } catch (e) {
      _biens = [];
    }
    _appliquerFiltres();
    _isLoading = false;
    notifyListeners();
  }

  void rechercher(String query) {
    _searchQuery = query;
    _appliquerFiltres();
  }

  void filtrerParVille(String ville) {
    _villeFiltre = ville;
    _appliquerFiltres();
  }

  void filtrerParTypeLocation(TypeLocation? type) {
    _typeLocationFiltre = type;
    _appliquerFiltres();
  }

  void filtrerParPrixMax(double? prix) {
    _prixMax = prix;
    _appliquerFiltres();
  }

  void _appliquerFiltres() {
    _biensFiltres = _biens.where((b) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!b.titre.toLowerCase().contains(q) &&
            !b.localisation.ville.toLowerCase().contains(q) &&
            !b.localisation.secteur.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_villeFiltre != 'Tous' && b.localisation.ville != _villeFiltre) {
        return false;
      }
      if (_typeLocationFiltre != null && b.typeLocation != _typeLocationFiltre) {
        return false;
      }
      if (_prixMax != null && b.prix > _prixMax!) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  List<Bien> getBiensProprietaire(int proprietaireId) {
    return _biens.where((b) => b.proprietaireId == proprietaireId).toList();
  }
}