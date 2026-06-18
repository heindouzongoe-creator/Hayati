class DemandeVisite {
  final String id;
  final String bienId;
  final String locataireId;
  final DateTime dateVisite;
  final String statut; // 'En attente', 'Acceptée', 'Refusée'

  DemandeVisite({
    required this.id,
    required this.bienId,
    required this.locataireId,
    required this.dateVisite,
    required this.statut,
  });

  // Convertit un JSON de l'API en objet Dart
  factory DemandeVisite.fromJson(Map<String, dynamic> json) {
    return DemandeVisite(
      id: json['id'],
      bienId: json['bienId'],
      locataireId: json['locataireId'],
      dateVisite: DateTime.parse(json['dateVisite']),
      statut: json['statut'],
    );
  }

  // Convertit l'objet Dart en JSON pour l'envoyer à l'API
  Map<String, dynamic> toJson() {
    return {
      'bienId': bienId,
      'locataireId': locataireId,
      'dateVisite': dateVisite.toIso8601String(),
      'statut': statut,
    };
  }
}