// lib/providers/auth_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
export 'proprietaire_provider.dart';


class AuthProvider extends ChangeNotifier {
  Utilisateur? _currentUser;
  bool _isLoading = false;
  String? _error;

  Utilisateur? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isLocataire => _currentUser?.role == RoleUtilisateur.locataire;
  bool get isProprietaire => _currentUser?.role == RoleUtilisateur.proprietaire;

  Future<bool> login(String email, String motDePasse) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulation appel API
    await Future.delayed(const Duration(seconds: 1));

   // backend 
    _error = 'Email ou mot de passe incorrect';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
    required RoleUtilisateur role,
    required String cnibNumero,
    required File cnibPhoto,
    required File selfiePhoto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = Utilisateur(
      id: DateTime.now().millisecondsSinceEpoch,
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      role: role,
      dateCreation: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> chargerSession() async {}

  Future<void> reloadUser() async {}
}

// bien_provider.dart
class BienProvider extends ChangeNotifier {
  List<Bien> _biens = [];
  List<Bien> _biensFiltres = [];
  Bien? _bienSelectionne;
  bool _isLoading = false;
  String _searchQuery = '';
  String _villeFiltre = 'Tous';
  TypeLocation? _typeLocationFiltre;
  double? _prixMax;

  List<Bien> get biens => _biensFiltres;
  List<Bien> get tousLesBiens => _biens;
  Bien? get bienSelectionne => _bienSelectionne;
  bool get isLoading => _isLoading;

  Future<void> chargerBiens() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));
    _biens =[];
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

  void selectionnerBien(Bien bien) {
    _bienSelectionne = bien;
    notifyListeners();
  }

  List<Bien> getBiensProprietaire(int proprietaireId) {
    return _biens.where((b) => b.proprietaireId == proprietaireId).toList();
  }

}
