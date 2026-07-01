enum RoleUtilisateur { locataire, proprietaire, agence, administrateur }
enum StatutBien { disponible, louer, reserve }
enum TypeBien { logement, localCommercial }
enum TypeLocation { sejour, longTerme }
enum StatutVisite { enAttente, confirme, refuse, annule }
enum StatutReservation { enAttente, confirme, annule }
enum StatutPaiement { valide, enAttente, echec }

class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final RoleUtilisateur role;
  final DateTime dateCreation;
  String? avatar;
  final bool estVerifie;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    required this.dateCreation,
    this.avatar,
    this.estVerifie = false,
  });

  String get nomComplet => '$prenom $nom';

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      role: RoleUtilisateur.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => RoleUtilisateur.locataire,
      ),
      dateCreation: DateTime.parse(json['created_at'] ?? json['dateCreation'] ?? DateTime.now().toIso8601String()),
      avatar: json['avatar'],
      estVerifie: json['est_verifie'] == true || json['est_verifie'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'nom': nom, 'prenom': prenom, 'email': email,
    'telephone': telephone, 'role': role.name,
    'dateCreation': dateCreation.toIso8601String(),
    'avatar': avatar, 'est_verifie': estVerifie,
  };
}

class Localisation {
  final int id;
  final String ville;
  final String secteur;
  final String adresse;
  final double? latitude;
  final double? longitude;

  Localisation({required this.id, required this.ville, required this.secteur, required this.adresse, this.latitude, this.longitude});

  String get adresseComplete => '$adresse, $secteur, $ville';

  factory Localisation.fromJson(Map<String, dynamic> json) {
    return Localisation(
      id: json['id'] ?? 0,
      ville: json['ville'] ?? '',
      secteur: json['secteur'] ?? '',
      adresse: json['adresse'] ?? json['quartier'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class Caracteristique {
  final int id;
  final String nom;
  final String valeur;

  Caracteristique({required this.id, required this.nom, required this.valeur});

  factory Caracteristique.fromJson(Map<String, dynamic> json) {
    return Caracteristique(id: json['id'], nom: json['nom'], valeur: json['valeur']);
  }
}

class Bien {
  final int id;
  final TypeBien typeBien;
  final String titre;
  final String description;
  final double prix;
  final StatutBien statut;
  final TypeLocation typeLocation;
  final Localisation localisation;
  final List<String> photos;
  final List<Caracteristique> caracteristiques;
  final int proprietaireId;
  final String proprietaireNom;
  final String proprietaireTelephone;
  final double? note;
  final int nombreAvis;
  final int? nombreChambres;
  final bool hasEau;
  final bool hasElectricite;
  final DateTime datePublication;

  Bien({
    required this.id, required this.typeBien, required this.titre,
    required this.description, required this.prix, required this.statut,
    required this.typeLocation, required this.localisation, required this.photos,
    required this.caracteristiques, required this.proprietaireId,
    required this.proprietaireNom, required this.proprietaireTelephone,
    this.note, this.nombreAvis = 0, this.nombreChambres,
    this.hasEau = false, this.hasElectricite = false, required this.datePublication,
  });

  bool get estDisponible => statut == StatutBien.disponible;

  factory Bien.fromJson(Map<String, dynamic> json) {
    final Localisation localisation;
    if (json['localisation'] != null) {
      localisation = Localisation.fromJson(json['localisation']);
    } else {
      localisation = Localisation(
        id: json['id'] ?? 0,
        ville: json['ville'] ?? '',
        secteur: json['secteur'] ?? '',
        adresse: json['quartier'] ?? json['secteur'] ?? '',
      );
    }
    return Bien(
      id: json['id'],
      typeBien: json['type_bien'] == 'local_commercial' ? TypeBien.localCommercial : TypeBien.logement,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      prix: (json['prix'] as num).toDouble(),
      statut: json['statut'] == 'loue' ? StatutBien.louer : json['statut'] == 'reserve' ? StatutBien.reserve : StatutBien.disponible,
      typeLocation: json['type_location'] == 'sejour' ? TypeLocation.sejour : TypeLocation.longTerme,
      localisation: localisation,
      photos: List<String>.from(json['photos'] ?? []),
      caracteristiques: [],
      proprietaireId: json['utilisateur_id'] ?? json['proprietaire_id'] ?? 0,
      proprietaireNom: json['proprietaire'] != null ? '${json['proprietaire']['prenom']} ${json['proprietaire']['nom']}' : '',
      proprietaireTelephone: json['proprietaire']?['telephone'] ?? '',
      note: (json['note_moyenne'] as num?)?.toDouble(),
      nombreAvis: json['nombre_avis'] ?? 0,
      nombreChambres: json['nombre_chambres'],
      hasEau: json['eau'] ?? false,
      hasElectricite: json['electricite'] ?? false,
      datePublication: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Reservation {
  final int id;
  final int bienId;
  final int locataireId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final double montantTotal;
  final String modePaiement;
  StatutReservation statut;
  final Bien? bien;

  Reservation({
    required this.id,
    required this.bienId,
    required this.locataireId,
    required this.dateDebut,
    required this.dateFin,
    required this.montantTotal,
    required this.modePaiement,
    required this.statut,
    this.bien,
  });

  int get nombreJours => dateFin.difference(dateDebut).inDays;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      bienId: json['bien_id'],
      locataireId: json['utilisateur_id'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      montantTotal: (json['montant_total'] as num).toDouble(),
      modePaiement: json['mode_paiement'] ?? 'ligdicash',
      statut: _parseStatut(json['statut']),
      bien: json['bien'] != null ? Bien.fromJson(json['bien']) : null,
    );
  }

  static StatutReservation _parseStatut(String? s) {
    switch (s) {
      case 'confirme': return StatutReservation.confirme;
      case 'annule':   return StatutReservation.annule;
      default:         return StatutReservation.enAttente;
    }
  }
}

class Visite {
  final int id;
  final int bienId;
  final int locataireId;
  final DateTime dateVisite;
  final String heureVisite;
  final String? message;
  StatutVisite statut;
  final Bien? bien;

  Visite({
    required this.id,
    required this.bienId,
    required this.locataireId,
    required this.dateVisite,
    required this.heureVisite,
    this.message,
    required this.statut,
    this.bien,
  });

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      id: json['id'],
      bienId: json['bien_id'],
      locataireId: json['utilisateur_id'],
      dateVisite: DateTime.parse(json['date_visite']),
      heureVisite: json['heure_visite'] ?? '',
      message: json['message'],
      statut: _parseStatut(json['statut']),
      bien: json['bien'] != null ? Bien.fromJson(json['bien']) : null,
    );
  }

  static StatutVisite _parseStatut(String? s) {
    switch (s) {
      case 'confirme': return StatutVisite.confirme;
      case 'refuse':   return StatutVisite.refuse;
      case 'annule':   return StatutVisite.annule;
      default:         return StatutVisite.enAttente;
    }
  }
}

class Avis {
  final int id;
  final int bienId;
  final int locataireId;
  final String locataireNom;
  final String? locataireAvatar;
  final double note;
  final String? commentaire;
  final DateTime dateAvis;

  Avis({
    required this.id,
    required this.bienId,
    required this.locataireId,
    required this.locataireNom,
    this.locataireAvatar,
    required this.note,
    this.commentaire,
    required this.dateAvis,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      id: json['id'],
      bienId: json['bien_id'],
      locataireId: json['utilisateur_id'],
      locataireNom: json['utilisateur'] != null ? '${json['utilisateur']['prenom']} ${json['utilisateur']['nom']}' : '',
      locataireAvatar: json['utilisateur']?['avatar'],
      note: (json['note'] as num).toDouble(),
      commentaire: json['commentaire'],
      dateAvis: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Notification {
  final int id;
  final int utilisateurId;
  final String titre;
  final String message;
  final String type;
  bool estLu;
  final DateTime dateEnvoi;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.utilisateurId,
    required this.titre,
    required this.message,
    required this.type,
    required this.estLu,
    required this.dateEnvoi,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      utilisateurId: json['utilisateur_id'],
      titre: json['titre'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      estLu: json['lu'] == true || json['lu'] == 1,
      dateEnvoi: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}


class Chambre {
  final int? id;
  final int bienId;
  final String type;
  final String nom;
  final double prix;
  final int capacite;
  final bool petitDejeuner;
  final bool dejeuner;
  final bool diner;
  final int nombreDisponible;

  Chambre({
    this.id,
    required this.bienId,
    required this.type,
    required this.nom,
    required this.prix,
    this.capacite = 1,
    this.petitDejeuner = false,
    this.dejeuner = false,
    this.diner = false,
    this.nombreDisponible = 1,
  });

  factory Chambre.fromJson(Map<String, dynamic> json) => Chambre(
    id:                json['id'],
    bienId:            json['bien_id'],
    type:              json['type'],
    nom:               json['nom'],
    prix:              double.parse(json['prix'].toString()),
    capacite:          json['capacite'] ?? 1,
    petitDejeuner:     json['petit_dejeuner'] == true || json['petit_dejeuner'] == 1,
    dejeuner:          json['dejeuner'] == true || json['dejeuner'] == 1,
    diner:             json['diner'] == true || json['diner'] == 1,
    nombreDisponible:  json['nombre_disponible'] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'bien_id':           bienId,
    'type':              type,
    'nom':               nom,
    'prix':              prix,
    'capacite':          capacite,
    'petit_dejeuner':    petitDejeuner,
    'dejeuner':          dejeuner,
    'diner':             diner,
    'nombre_disponible': nombreDisponible,
  };
}