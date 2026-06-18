import 'type_bien.dart';

class Unite {
  final String id;
  final String bienId;
  final String nom; // ex: "Chambre 12", "Boutique A"
  final TypeUnite typeUnite;
  final int capacite;
  final double? surface; // en m²
  final double prix;
  StatutUnite statut;

  Unite({
    required this.id,
    required this.bienId,
    required this.nom,
    required this.typeUnite,
    required this.capacite,
    this.surface,
    required this.prix,
    this.statut = StatutUnite.libre,
  });

  Unite copyWith({
    String? id,
    String? bienId,
    String? nom,
    TypeUnite? typeUnite,
    int? capacite,
    double? surface,
    double? prix,
    StatutUnite? statut,
  }) {
    return Unite(
      id: id ?? this.id,
      bienId: bienId ?? this.bienId,
      nom: nom ?? this.nom,
      typeUnite: typeUnite ?? this.typeUnite,
      capacite: capacite ?? this.capacite,
      surface: surface ?? this.surface,
      prix: prix ?? this.prix,
      statut: statut ?? this.statut,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bienId': bienId,
      'nom': nom,
      'typeUnite': typeUnite.name,
      'capacite': capacite,
      'surface': surface,
      'prix': prix,
      'statut': statut.name,
    };
  }

  factory Unite.fromJson(Map<String, dynamic> json) {
    return Unite(
      id: json['id'],
      bienId: json['bienId'],
      nom: json['nom'],
      typeUnite: TypeUnite.values.byName(json['typeUnite']),
      capacite: json['capacite'],
      surface: json['surface']?.toDouble(),
      prix: json['prix'].toDouble(),
      statut: StatutUnite.values.byName(json['statut']),
    );
  }
}