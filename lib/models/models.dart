// lib/models/models.dart

enum RoleUtilisateur { locataire, proprietaire, agence, administrateur }
enum StatutBien { disponible, louer, reserve }
enum TypeBien { logement, localCommercial }
enum TypeLocation { sejour, longTerme }
enum StatutVisite { enAttente, acceptee, refusee }
enum StatutReservation { confirmee, annulee, enAttente }
enum StatutPaiement { valide, enAttente, echec }
enum Loueur { proprietaire, agence, demarcheur }

class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final RoleUtilisateur role;
  final DateTime dateCreation;
  String? avatar;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    required this.dateCreation,
    this.avatar,
  });

  String get nomComplet => '$prenom $nom';

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'] ?? '',
      role: RoleUtilisateur.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => RoleUtilisateur.locataire,
      ),

      dateCreation: DateTime.parse(json['created_at'] ?? json['dateCreation'] ?? DateTime.now().toIso8601String()),
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'role': role.name,
        'dateCreation': dateCreation.toIso8601String(),
        'avatar': avatar,
      };
}

class Localisation {
  final int id;
  final String ville;
  final String secteur;
  final String adresse;
  final double? latitude;
  final double? longitude;

  Localisation({
    required this.id,
    required this.ville,
    required this.secteur,
    required this.adresse,
    this.latitude,
    this.longitude,
  });

  String get adresseComplete => '$adresse, $secteur, $ville';

  factory Localisation.fromJson(Map<String, dynamic> json) {
    return Localisation(
      id: json['id'],
      ville: json['ville'],
      secteur: json['secteur'],
      adresse: json['adresse'],
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
    return Caracteristique(
      id: json['id'],
      nom: json['nom'],
      valeur: json['valeur'],
    );
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
    required this.id,
    required this.typeBien,
    required this.titre,
    required this.description,
    required this.prix,
    required this.statut,
    required this.typeLocation,
    required this.localisation,
    required this.photos,
    required this.caracteristiques,
    required this.proprietaireId,
    required this.proprietaireNom,
    required this.proprietaireTelephone,
    this.note,
    this.nombreAvis = 0,
    this.nombreChambres,
    this.hasEau = false,
    this.hasElectricite = false,
    required this.datePublication,
  });

  bool get estDisponible => statut == StatutBien.disponible;

 factory Bien.fromJson(Map<String, dynamic> json) {
  // Localisation : soit objet séparé soit champs directs
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
    typeBien: json['type_bien'] == 'local_commercial'
        ? TypeBien.localCommercial
        : TypeBien.logement,
    titre: json['titre'] ?? '',
    description: json['description'] ?? '',
    prix: (json['prix'] as num).toDouble(),
    statut: json['statut'] == 'loue'
        ? StatutBien.louer
        : json['statut'] == 'reserve'
            ? StatutBien.reserve
            : StatutBien.disponible,
    typeLocation: json['type_location'] == 'sejour'
        ? TypeLocation.sejour
        : TypeLocation.longTerme,
    localisation: localisation,
    photos: List<String>.from(json['photos'] ?? []),
    caracteristiques: [],
    proprietaireId: json['utilisateur_id'] ?? json['proprietaire_id'] ?? 0,
    proprietaireNom: json['proprietaire'] != null
        ? '${json['proprietaire']['prenom']} ${json['proprietaire']['nom']}'
        : '',
    proprietaireTelephone: json['proprietaire'] != null
        ? json['proprietaire']['telephone'] ?? ''
        : '',
    note: (json['note_moyenne'] as num?)?.toDouble(),
    nombreAvis: json['nombre_avis'] ?? 0,
    nombreChambres: json['nombre_chambres'],
    hasEau: json['eau'] ?? false,
    hasElectricite: json['electricite'] ?? false,
    datePublication: DateTime.parse(
      json['created_at'] ?? DateTime.now().toIso8601String(),
    ),
  );
}
}

class OffreLocation {
  final int id;
  final DateTime datePublication;
  final String statut;
  final Bien bien;

  OffreLocation({
    required this.id,
    required this.datePublication,
    required this.statut,
    required this.bien,
  });
}

class Visite {
  final int id;
  final DateTime dateVisite;
  StatutVisite statut;
  final int locataireId;
  final int bienId;
  final String bienTitre;
  final String locataireNom;

  Visite({
    required this.id,
    required this.dateVisite,
    required this.statut,
    required this.locataireId,
    required this.bienId,
    required this.bienTitre,
    required this.locataireNom,
  });
}

class Reservation {
  final int id;
  final DateTime dateDebut;
  final DateTime dateFin;
  StatutReservation statut;
  final int locataireId;
  final int bienId;
  final String bienTitre;
  final double montantTotal;
  final String? photo;

  Reservation({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.locataireId,
    required this.bienId,
    required this.bienTitre,
    required this.montantTotal,
    this.photo,
  });

  int get nombreJours => dateFin.difference(dateDebut).inDays;
}

class Paiement {
  final int id;
  final double montant;
  final DateTime datePaiement;
  final String modePaiement;
  final StatutPaiement statut;
  final int reservationId;

  Paiement({
    required this.id,
    required this.montant,
    required this.datePaiement,
    required this.modePaiement,
    required this.statut,
    required this.reservationId,
  });
}

class ContratLocation {
  final int id;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final double montantLoyer;
  final double caution;
  final int locataireId;
  final int proprietaireId;
  final int bienId;
  final String bienTitre;

  ContratLocation({
    required this.id,
    required this.dateDebut,
    this.dateFin,
    required this.montantLoyer,
    required this.caution,
    required this.locataireId,
    required this.proprietaireId,
    required this.bienId,
    required this.bienTitre,
  });
}

class Avis {
  final int id;
  final int note;
  final String commentaire;
  final DateTime dateAvis;
  final int locataireId;
  final String locataireNom;
  final String? locataireAvatar;
  final int bienId;

  Avis({
    required this.id,
    required this.note,
    required this.commentaire,
    required this.dateAvis,
    required this.locataireId,
    required this.locataireNom,
    this.locataireAvatar,
    required this.bienId,
  });
}

class Notification {
  final int id;
  final String message;
  final DateTime dateEnvoi;
  bool estLu;
  final int utilisateurId;

  Notification({
    required this.id,
    required this.message,
    required this.dateEnvoi,
    required this.estLu,
    required this.utilisateurId,
  });
}
/*
// Données de démonstration
class DemoData {
  static List<Bien> getBiens() {
    return [
      Bien(
        id: 1,
        typeBien: TypeBien.logement,
        titre: 'Belle villa F4 à Ouaga 2000',
        description:
            'Magnifique villa avec jardin, sécurisée, proche du goudron. Idéale pour famille. Eau et électricité disponibles 24h/24.',
        prix: 150000,
        statut: StatutBien.disponible,
        typeLocation: TypeLocation.longTerme,
        localisation: Localisation(
          id: 1,
          ville: 'Ouagadougou',
          secteur: 'Secteur 15 - Ouaga 2000',
          adresse: 'Rue 15.25',
        ),
        photos: [
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
          'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
        ],
        caracteristiques: [
          Caracteristique(id: 1, nom: 'Chambres', valeur: '4'),
          Caracteristique(id: 2, nom: 'Douches', valeur: '2'),
          Caracteristique(id: 3, nom: 'Salon', valeur: 'Oui'),
          Caracteristique(id: 4, nom: 'Parking', valeur: 'Oui'),
          Caracteristique(id: 5, nom: 'Jardin', valeur: 'Oui'),
        ],
        proprietaireId: 1,
        proprietaireNom: 'Ouédraogo Rasmané',
        proprietaireTelephone: '+226 70 00 00 01',
        note: 4.5,
        nombreAvis: 12,
        nombreChambres: 4,
        hasEau: true,
        hasElectricite: true,
        datePublication: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Bien(
        id: 2,
        typeBien: TypeBien.logement,
        titre: 'Appartement F2 meublé - Bobo',
        description:
            'Appartement moderne entièrement meublé, idéal pour étudiants ou jeunes professionnels. Climatisé, wifi disponible.',
        prix: 45000,
        statut: StatutBien.disponible,
        typeLocation: TypeLocation.longTerme,
        localisation: Localisation(
          id: 2,
          ville: 'Bobo-Dioulasso',
          secteur: 'Secteur 8 - Bindougousso',
          adresse: 'Avenue Dioulassoba',
        ),
        photos: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        ],
        caracteristiques: [
          Caracteristique(id: 6, nom: 'Chambres', valeur: '2'),
          Caracteristique(id: 7, nom: 'Douches', valeur: '1'),
          Caracteristique(id: 8, nom: 'Meublé', valeur: 'Oui'),
          Caracteristique(id: 9, nom: 'Climatisé', valeur: 'Oui'),
        ],
        proprietaireId: 2,
        proprietaireNom: 'Traoré Aminata',
        proprietaireTelephone: '+226 76 00 00 02',
        note: 4.2,
        nombreAvis: 8,
        nombreChambres: 2,
        hasEau: true,
        hasElectricite: true,
        datePublication: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Bien(
        id: 3,
        typeBien: TypeBien.logement,
        titre: 'Chambre en cour commune - Pissy',
        description:
            'Chambre disponible dans cour commune tranquille. Ambiance familiale, voisins sympas. Proche marché.',
        prix: 15000,
        statut: StatutBien.disponible,
        typeLocation: TypeLocation.longTerme,
        localisation: Localisation(
          id: 3,
          ville: 'Ouagadougou',
          secteur: 'Secteur 17 - Pissy',
          adresse: 'Rue Pissy 08',
        ),
        photos: [
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
        ],
        caracteristiques: [
          Caracteristique(id: 10, nom: 'Type', valeur: 'Cour commune'),
          Caracteristique(id: 11, nom: 'Douche', valeur: 'Partagée'),
        ],
        proprietaireId: 3,
        proprietaireNom: 'Compaoré Adama',
        proprietaireTelephone: '+226 65 00 00 03',
        note: 3.8,
        nombreAvis: 5,
        nombreChambres: 1,
        hasEau: true,
        hasElectricite: true,
        datePublication: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Bien(
        id: 4,
        typeBien: TypeBien.logement,
        titre: 'Résidence meublée - Nuit',
        description:
            'Résidence de standing pour voyageurs. Chambre confortable avec AC, TV, wifi. Petit-déjeuner inclus.',
        prix: 15000,
        statut: StatutBien.disponible,
        typeLocation: TypeLocation.sejour,
        localisation: Localisation(
          id: 4,
          ville: 'Ouagadougou',
          secteur: 'Secteur 4 - Zone du Bois',
          adresse: 'Avenue Kwame N\'Krumah',
        ),
        photos: [
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
          'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
        ],
        caracteristiques: [
          Caracteristique(id: 12, nom: 'Type', valeur: 'Résidence'),
          Caracteristique(id: 13, nom: 'Wifi', valeur: 'Oui'),
          Caracteristique(id: 14, nom: 'TV', valeur: 'Oui'),
          Caracteristique(id: 15, nom: 'Petit-déj', valeur: 'Inclus'),
        ],
        proprietaireId: 4,
        proprietaireNom: 'Résidence Wend-Panga',
        proprietaireTelephone: '+226 25 00 00 04',
        note: 4.7,
        nombreAvis: 34,
        nombreChambres: 1,
        hasEau: true,
        hasElectricite: true,
        datePublication: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Bien(
        id: 5,
        typeBien: TypeBien.localCommercial,
        titre: 'Boutique 30m² - Marché Rood Woko',
        description:
            'Local commercial idéalement situé proche du marché central. Fort passage. Idéal pour commerce de détail.',
        prix: 80000,
        statut: StatutBien.disponible,
        typeLocation: TypeLocation.longTerme,
        localisation: Localisation(
          id: 5,
          ville: 'Ouagadougou',
          secteur: 'Secteur 1 - Centre-ville',
          adresse: 'Rue du Commerce',
        ),
        photos: [
          'https://images.unsplash.com/photo-1604328698692-f76ea9498e76?w=800',
        ],
        caracteristiques: [
          Caracteristique(id: 16, nom: 'Surface', valeur: '30m²'),
          Caracteristique(id: 17, nom: 'Type', valeur: 'Boutique'),
          Caracteristique(id: 18, nom: 'Vitrine', valeur: 'Oui'),
        ],
        proprietaireId: 5,
        proprietaireNom: 'Sawadogo Issouf',
        proprietaireTelephone: '+226 70 00 00 05',
        note: 4.0,
        nombreAvis: 3,
        hasEau: false,
        hasElectricite: true,
        datePublication: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  static List<Avis> getAvis(int bienId) {
    return [
      Avis(
        id: 1,
        note: 5,
        commentaire: 'Excellent logement, propriétaire très sympa. Je recommande vivement !',
        dateAvis: DateTime.now().subtract(const Duration(days: 30)),
        locataireId: 10,
        locataireNom: 'Kaboré Fatou',
        bienId: bienId,
      ),
      Avis(
        id: 2,
        note: 4,
        commentaire: 'Bien situé, propre. Juste le bruit de la rue parfois.',
        dateAvis: DateTime.now().subtract(const Duration(days: 60)),
        locataireId: 11,
        locataireNom: 'Zongo Pierre',
        bienId: bienId,
      ),
      Avis(
        id: 3,
        note: 4,
        commentaire: 'Très bon rapport qualité-prix pour Ouaga.',
        dateAvis: DateTime.now().subtract(const Duration(days: 90)),
        locataireId: 12,
        locataireNom: 'Diallo Mariama',
        bienId: bienId,
      ),
    ];
  }

  static List<Notification> getNotifications() {
    return [
      Notification(
        id: 1,
        message: 'Votre demande de visite a été acceptée pour "Villa F4 Ouaga 2000"',
        dateEnvoi: DateTime.now().subtract(const Duration(hours: 2)),
        estLu: false,
        utilisateurId: 1,
      ),
      Notification(
        id: 2,
        message: 'Nouveau message de Ouédraogo Rasmané concernant votre réservation',
        dateEnvoi: DateTime.now().subtract(const Duration(hours: 5)),
        estLu: false,
        utilisateurId: 1,
      ),
      Notification(
        id: 3,
        message: 'Votre paiement de 45 000 FCFA a été confirmé',
        dateEnvoi: DateTime.now().subtract(const Duration(days: 1)),
        estLu: true,
        utilisateurId: 1,
      ),
    ];
  }
}*/
