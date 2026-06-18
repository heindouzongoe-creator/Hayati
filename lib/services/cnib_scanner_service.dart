import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CnibInfo {
  final String? numero;
  final String? nom;
  final String? prenom;
  final String? dateNaissance;
  final String? lieuNaissance;
  final String? sexe;
  final String? profession;
  final String? dateDelivrance;
  final String? dateExpiration;
  final String? lieuDelivrance;

  CnibInfo({
    this.numero,
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.lieuNaissance,
    this.sexe,
    this.profession,
    this.dateDelivrance,
    this.dateExpiration,
    this.lieuDelivrance,
  });

  bool get estVide => numero == null && nom == null && prenom == null && dateNaissance == null;
}

class CnibScannerService {
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<CnibInfo> scanner(File photo) async {
    final inputImage = InputImage.fromFile(photo);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    final texte = recognizedText.text;
    final lignes = texte.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    print('=== TEXTE SCANNÉ ===\n$texte\n====================');

    return CnibInfo(
      numero:         _extraireNumero(lignes),
      nom:            _extraireNom(lignes),
      prenom:         _extrairePrenom(lignes),
      dateNaissance:  _extraireDateNaissance(lignes),
      lieuNaissance:  _extraireLieuNaissance(lignes),
      sexe:           _extraireSexe(lignes),
      profession:     _extraireProfession(lignes),
      dateDelivrance: _extraireDateDelivrance(lignes),
      dateExpiration: _extraireDateExpiration(lignes),
      lieuDelivrance: _extraireLieuDelivrance(lignes),
    );
  }

  /// Numéro CNIB — format Burkina : B12101520
  static String? _extraireNumero(List<String> lignes) {
    final regex = RegExp(r'\b[A-Z]{1,2}\d{6,9}\b', caseSensitive: false);
    for (final ligne in lignes) {
      final match = regex.firstMatch(ligne.replaceAll(' ', ''));
      if (match != null) return match.group(0)?.toUpperCase();
    }
    return null;
  }

  /// Nom — "Nom: GUIEBRE"
  static String? _extraireNom(List<String> lignes) {
    for (int i = 0; i < lignes.length; i++) {
      final upper = lignes[i].toUpperCase();
      if (upper.startsWith('NOM:') || upper.startsWith('NOM :')) {
        final parts = lignes[i].split(RegExp(r':\s*'));
        if (parts.length > 1 && parts.last.trim().isNotEmpty) return parts.last.trim().toUpperCase();
      }
      if (upper == 'NOM' && i + 1 < lignes.length) return lignes[i + 1].trim().toUpperCase();
    }
    return null;
  }

  /// Prénom — "Prénoms: TESLIM KOYEMBO RASIF"
  static String? _extrairePrenom(List<String> lignes) {
    for (int i = 0; i < lignes.length; i++) {
      final upper = lignes[i].toUpperCase();
      if (upper.contains('PRÉNOM') || upper.contains('PRENOM')) {
        final parts = lignes[i].split(RegExp(r':\s*'));
        if (parts.length > 1 && parts.last.trim().isNotEmpty) return parts.last.trim();
        if (i + 1 < lignes.length) return lignes[i + 1].trim();
      }
    }
    return null;
  }

  /// Date de naissance — "Né(e) le: 29/09/2003 A BOBO-DIOULASSO"
  static String? _extraireDateNaissance(List<String> lignes) {
    final dateRegex = RegExp(r'\d{2}[/\-\.]\d{2}[/\-\.]\d{4}');
    for (final ligne in lignes) {
      final upper = ligne.toUpperCase();
      if (upper.contains('NÉ') || upper.contains('NE ') || upper.contains('NAISSANCE')) {
        final match = dateRegex.firstMatch(ligne);
        if (match != null) return match.group(0);
      }
    }
    // Fallback : première date trouvée
    for (final ligne in lignes) {
      final match = dateRegex.firstMatch(ligne);
      if (match != null) return match.group(0);
    }
    return null;
  }

  /// Lieu de naissance — extrait "BOBO-DIOULASSO" de "Né(e) le: 29/09/2003 A BOBO-DIOULASSO"
  static String? _extraireLieuNaissance(List<String> lignes) {
    for (final ligne in lignes) {
      final upper = ligne.toUpperCase();
      if (upper.contains('NÉ') || upper.contains('NE ') || upper.contains('NAISSANCE')) {
        // Cherche " A " ou " À " suivi du lieu
        final match = RegExp(r'[AÀ]\s+([A-ZÀÂÉÈÊËÎÏÔÙÛÜ][A-Z0-9À-Ÿ\s\-]+)$', caseSensitive: false).firstMatch(ligne);
        if (match != null && match.group(1) != null) {
          return match.group(1)!.trim();
        }
      }
    }
    return null;
  }

  /// Sexe — "Sexe: M" ou "Sexe: F"
  static String? _extraireSexe(List<String> lignes) {
    for (final ligne in lignes) {
      final upper = ligne.toUpperCase();
      if (upper.contains('SEXE')) {
        final match = RegExp(r'SEXE\s*:\s*([MF])', caseSensitive: false).firstMatch(ligne);
        if (match != null) return match.group(1)!.toUpperCase();
      }
    }
    return null;
  }

  /// Profession — "Profession: ELEVE"
  static String? _extraireProfession(List<String> lignes) {
    for (int i = 0; i < lignes.length; i++) {
      final upper = lignes[i].toUpperCase();
      if (upper.contains('PROFESSION') || upper.contains('OCCUPATION')) {
        final parts = lignes[i].split(RegExp(r':\s*'));
        if (parts.length > 1 && parts.last.trim().isNotEmpty) return parts.last.trim();
        if (i + 1 < lignes.length) return lignes[i + 1].trim();
      }
    }
    return null;
  }

  /// Date de délivrance — ligne "Délivrée le:" suivie de la date
  static String? _extraireDateDelivrance(List<String> lignes) {
    final dateRegex = RegExp(r'\d{2}[/\-\.]\d{2}[/\-\.]\d{4}');
    for (int i = 0; i < lignes.length; i++) {
      final upper = lignes[i].toUpperCase();
      if (upper.contains('DÉLIVR') || upper.contains('DELIVR')) {
        // Date sur la même ligne
        final match = dateRegex.firstMatch(lignes[i]);
        if (match != null) return match.group(0);
        // Date sur la ligne suivante
        if (i + 1 < lignes.length) {
          final matchNext = dateRegex.firstMatch(lignes[i + 1]);
          if (matchNext != null) return matchNext.group(0);
        }
      }
    }
    // Fallback : deuxième date trouvée
    final dates = <String>[];
    for (final ligne in lignes) {
      for (final match in dateRegex.allMatches(ligne)) {
        if (!dates.contains(match.group(0)!)) dates.add(match.group(0)!);
      }
    }
    return dates.length > 1 ? dates[1] : null;
  }

  /// Date d'expiration — ligne "Expire le:" suivie de la date
  static String? _extraireDateExpiration(List<String> lignes) {
    final dateRegex = RegExp(r'\d{2}[/\-\.]\d{2}[/\-\.]\d{4}');
    for (int i = 0; i < lignes.length; i++) {
      final upper = lignes[i].toUpperCase();
      if (upper.contains('EXPIR') || upper.contains('VALID')) {
        final match = dateRegex.firstMatch(lignes[i]);
        if (match != null) return match.group(0);
        if (i + 1 < lignes.length) {
          final matchNext = dateRegex.firstMatch(lignes[i + 1]);
          if (matchNext != null) return matchNext.group(0);
        }
      }
    }
    // Fallback : première date trouvée (expiration = plus récente)
    final dates = <String>[];
    for (final ligne in lignes) {
      for (final match in dateRegex.allMatches(ligne)) {
        if (!dates.contains(match.group(0)!)) dates.add(match.group(0)!);
      }
    }
    return dates.isNotEmpty ? dates.first : null;
  }

  /// Lieu de délivrance — souvent absent sur la CNIB burkinabè
  static String? _extraireLieuDelivrance(List<String> lignes) {
    for (int i = 0; i < lignes.length; i++) {
      final upper = lignes[i].toUpperCase();
      if (upper.contains('DÉLIVR') || upper.contains('DELIVR')) {
        // Cherche un lieu après "à" ou "a"
        final match = RegExp(r'[AÀ]\s+([A-ZÀÂÉÈÊËÎÏÔÙÛÜ][A-Z0-9À-Ÿ\s\-]+)$', caseSensitive: false).firstMatch(lignes[i]);
        if (match != null) return match.group(1)?.trim();
      }
    }
    return null;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
