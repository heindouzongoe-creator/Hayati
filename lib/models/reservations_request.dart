enum ReservationStatus {
  enAttente,
  accepte,
  refuse,
  annule
}

class ReservationRequest {
  final String id;
  final String locataireId;
  final String offreLocationId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? message;
  final String status;

  ReservationRequest({
    required this.id,
    required this.locataireId,
    required this.offreLocationId,
    required this.dateDebut,
    required this.dateFin,
    this.message,
    required this.status,
  });

  // Convertit le JSON reçu de l'API Laravel en objet Dart
  factory ReservationRequest.fromJson(Map<String, dynamic> json) {
    return ReservationRequest(
      id: json['id']?.toString() ?? '',
      locataireId: json['locataire_id']?.toString() ?? '',
      offreLocationId: json['offre_location_id']?.toString() ?? '',
      dateDebut: json['date_debut'] != null 
          ? DateTime.parse(json['date_debut']) 
          : DateTime.now(),
      dateFin: json['date_fin'] != null 
          ? DateTime.parse(json['date_fin']) 
          : DateTime.now(),
      message: json['message'],
      status: json['status'] ?? 'enAttente',
    );
  }

  // Convertit l'objet Dart en JSON si besoin de l'envoyer
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locataire_id': locataireId,
      'offre_location_id': offreLocationId,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'message': message,
      'status': status,
    };
  }
}