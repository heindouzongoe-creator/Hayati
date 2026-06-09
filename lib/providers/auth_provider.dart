// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'dart:io';
import '../services/api_service.dart';

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

  Future<bool> login(String identifiant, String motDePasse) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final result = await ApiService.login(
      identifiant: identifiant,
      password: motDePasse,
    );
    ApiService.setToken(result['data']['token']);
    _currentUser = Utilisateur.fromJson(result['data']['user']);

    // ── Sauvegarde locale ──
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', result['data']['token']);
    await prefs.setString('dernier_identifiant', identifiant);

    _isLoading = false;
    notifyListeners();
    return true;
  } on ApiException catch (e) {
    _error = e.message;
    _isLoading = false;
    notifyListeners();
    return false;
  } catch (e) {
    _error = 'Erreur de connexion au serveur';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
Future<void> chargerSession() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token != null) {
    ApiService.setToken(token);
    try {
      final result = await ApiService.getMe();
      _currentUser = Utilisateur.fromJson(result['data']);
      notifyListeners();
    } catch (_) {
      // Token expiré — on nettoie
      await prefs.remove('token');
      ApiService.clearToken();
    }
  }
}

  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
    required String cnibNumero,
    required File cnibPhotoPath,
    required File selfiePhotoPath,
    required RoleUtilisateur role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        password: motDePasse,
        role: role == RoleUtilisateur.proprietaire ? 'proprietaire' : 'locataire',
      cnibNumero: cnibNumero,
      cnibPhoto: cnibPhotoPath,
      selfiePhoto: selfiePhotoPath,
      );
      final data = res['data'];
      ApiService.setToken(data['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      final u = data['user'];
      _currentUser = Utilisateur(
        id: u['id'],
        nom: u['nom'],
        prenom: u['prenom'],
        email: u['email'],
        telephone: u['telephone'] ?? '',
        role: role,
        dateCreation: DateTime.parse(u['created_at']),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur de connexion. Vérifiez votre réseau.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

Future<void> reloadUser() async {
  try {
    final result = await ApiService.getMe();
    _currentUser = Utilisateur.fromJson(result['data']);
    notifyListeners();
  } catch (_) {}
}
  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    ApiService.clearToken();
    _currentUser = null;
    notifyListeners();
  }
}