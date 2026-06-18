enum TypeBien {
  hotel,
  auberge,
  villa,
  habitation,
  localCommercial,
}

extension TypeBienExtension on TypeBien {
  String get label {
    switch (this) {
      case TypeBien.hotel:
        return 'Hôtel';
      case TypeBien.auberge:
        return 'Auberge';
      case TypeBien.villa:
        return 'Villa';
      case TypeBien.habitation:
        return 'Habitation';
      case TypeBien.localCommercial:
        return 'Local commercial';
    }
  }

  /// Indique si ce type de bien peut avoir des unités (chambres, boutiques...)
  bool get peutAvoirUnites {
    switch (this) {
      case TypeBien.hotel:
      case TypeBien.auberge:
      case TypeBien.localCommercial:
        return true;
      case TypeBien.villa:
      case TypeBien.habitation:
        return false;
    }
  }
}

enum TypeUnite {
  chambre,
  dortoir,
  bureau,
  boutique,
}

extension TypeUniteExtension on TypeUnite {
  String get label {
    switch (this) {
      case TypeUnite.chambre:
        return 'Chambre';
      case TypeUnite.dortoir:
        return 'Dortoir';
      case TypeUnite.bureau:
        return 'Bureau';
      case TypeUnite.boutique:
        return 'Boutique';
    }
  }
}

enum StatutBien {
  disponible,
  occupe,
  enTravaux,
}

extension StatutBienExtension on StatutBien {
  String get label {
    switch (this) {
      case StatutBien.disponible:
        return 'Disponible';
      case StatutBien.occupe:
        return 'Occupé';
      case StatutBien.enTravaux:
        return 'En travaux';
    }
  }
}

enum StatutUnite {
  libre,
  occupee,
}

extension StatutUniteExtension on StatutUnite {
  String get label {
    switch (this) {
      case StatutUnite.libre:
        return 'Libre';
      case StatutUnite.occupee:
        return 'Occupée';
    }
  }
}