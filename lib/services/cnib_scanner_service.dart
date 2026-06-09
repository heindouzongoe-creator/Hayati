import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CnibInfo {
  final String? numero;
  final String? nom;
  final String? prenom;
  final String? dateNaissance;
  final String? dateExpiration;
  final String? lieuNaissance;

  CnibInfo({
    this.numero,
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.dateExpiration,
    this.lieuNaissance,
  });

  bool get estVide =>
      numero == null &&
      nom == null &&
      prenom == null &&
      dateNaissance == null;
}

class CnibScannerService {
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Scanne une photo de CNIB et extrait les informations
  static Future<CnibInfo> scanner(File photo) async {
    final inputImage = InputImage.fromFile(photo);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    final texte = recognizedText.text;
    final lignes = texte.split('\n').map((l) => l.trim()).toList();

    return CnibInfo(
      numero: _extraireNumero(lignes),
      nom: _extraireNom(lignes),
      prenom: _extrairePrenom(lignes),
      dateNaissance: _extraireDate(lignes, 'naissance'),
      dateExpiration: _extraireDate(lignes, 'expiration'),
      lieuNaissance: _extraireLieu(lignes),
    );
  }

  /// Numéro CNIB — format Burkina : ex B1234567 ou BCNIB12345
  static String? _extraireNumero(List<String> lignes) {
    final regex = RegExp(r'[A-Z]{1,2}\d{6,8}', caseSensitive: false);
    for (final ligne in lignes) {
      final match = regex.firstMatch(ligne.replaceAll(' ', ''));
      if (match != null) return match.group(0)?.toUpperCase();
    }
    return null;
  }

  /// Nom — généralement en majuscules sur la CNIB
  static String? _extraireNom(List<String> lignes) {
    for (int i = 0; i < lignes.length; i++) {
      final ligne = lignes[i];
      // Cherche une ligne qui contient NOM ou NAME
      if (ligne.toUpperCase().contains('NOM') ||
          ligne.toUpperCase().contains('NAME')) {
        // Le nom est souvent sur la même ligne après ":" ou sur la ligne suivante
        final parts = ligne.split(RegExp(r'[:/]'));
        if (parts.length > 1 && parts.last.trim().isNotEmpty) {
          return parts.last.trim().toUpperCase();
        }
        if (i + 1 < lignes.length) {
          return lignes[i + 1].trim().toUpperCase();
        }
      }
    }
    // Fallback : cherche une ligne toute en majuscules de 3+ mots
    for (final ligne in lignes) {
      if (ligne == ligne.toUpperCase() &&
          ligne.split(' ').isNotEmpty &&
          ligne.length > 3 &&
          !ligne.contains(RegExp(r'\d'))) {
        return ligne.trim();
      }
    }
    return null;
  }

  /// Prénom
  static String? _extrairePrenom(List<String> lignes) {
    for (int i = 0; i < lignes.length; i++) {
      final ligne = lignes[i];
      if (ligne.toUpperCase().contains('PRÉNOM') ||
          ligne.toUpperCase().contains('PRENOM') ||
          ligne.toUpperCase().contains('GIVEN') ||
          ligne.toUpperCase().contains('FIRST')) {
        final parts = ligne.split(RegExp(r'[:/]'));
        if (parts.length > 1 && parts.last.trim().isNotEmpty) {
          return parts.last.trim();
        }
        if (i + 1 < lignes.length) {
          return lignes[i + 1].trim();
        }
      }
    }
    return null;
  }

  /// Date — naissance ou expiration
  static String? _extraireDate(List<String> lignes, String type) {
    final motCle = type == 'naissance'
        ? RegExp(r'naissance|birth|né|born', caseSensitive: false)
        : RegExp(r'expir|valid|fin|expire', caseSensitive: false);

    final dateRegex = RegExp(r'\d{2}[/\-\.]\d{2}[/\-\.]\d{4}');

    for (int i = 0; i < lignes.length; i++) {
      if (motCle.hasMatch(lignes[i])) {
        // Cherche une date sur cette ligne ou la suivante
        for (int j = i; j <= i + 1 && j < lignes.length; j++) {
          final match = dateRegex.firstMatch(lignes[j]);
          if (match != null) return match.group(0);
        }
      }
    }

    // Fallback : retourne toutes les dates trouvées dans l'ordre
    final dates = <String>[];
    for (final ligne in lignes) {
      final match = dateRegex.firstMatch(ligne);
      if (match != null) dates.add(match.group(0)!);
    }

    if (type == 'naissance' && dates.isNotEmpty) return dates.first;
    if (type == 'expiration' && dates.length > 1) return dates.last;
    return null;
  }

  /// Lieu de naissance
  static String? _extraireLieu(List<String> lignes) {
    for (int i = 0; i < lignes.length; i++) {
      final ligne = lignes[i];
      if (ligne.toUpperCase().contains('LIEU') ||
          ligne.toUpperCase().contains('PLACE') ||
          ligne.toUpperCase().contains('NÉ À') ||
          ligne.toUpperCase().contains('NE A')) {
        final parts = ligne.split(RegExp(r'[:/]'));
        if (parts.length > 1 && parts.last.trim().isNotEmpty) {
          return parts.last.trim();
        }
        if (i + 1 < lignes.length) return lignes[i + 1].trim();
      }
    }
    return null;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}