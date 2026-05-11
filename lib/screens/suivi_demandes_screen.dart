// ignore_for_file: equal_keys_in_map

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
//import '../services/visite_service.dart';
//import '../services/reservation_service.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
 
class SuiviDemandesScreen extends StatefulWidget {
  const SuiviDemandesScreen({super.key});
 
  @override
  State<SuiviDemandesScreen> createState() => _SuiviDemandesScreenState();
}
 
class _SuiviDemandesScreenState extends State<SuiviDemandesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Visite> _visites = [];
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  
  // ignore: non_constant_identifier_names
  dynamic get VisiteService => null;
 
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _charger();
  }
 
  Future<void> _charger() async {
    setState(() => _isLoading = true);
    try {
     final visites = await VisiteService.getMesVisites();
      // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
      var ReservationService;
      final reservations = await ReservationService.getMesReservations();
      setState(() {
        _visites = visites;
        _reservations = reservations;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes demandes'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Visites (${_visites.length})'),
            Tab(text: 'Réservations (${_reservations.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ImmoFasoTheme.primary))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                // Onglet Visites
                _visites.isEmpty
                    ? const EmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: 'Aucune visite demandée',
                      )
                    : RefreshIndicator(
                        onRefresh: _charger,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _visites.length,
                          itemBuilder: (_, i) => _VisiteCard(visite: _visites[i]),
                        ),
                      ),
 
                // Onglet Réservations
                _reservations.isEmpty
                    ? const EmptyState(
                        icon: Icons.bookmark_outline,
                        title: 'Aucune réservation',
                      )
                    : RefreshIndicator(
                        onRefresh: _charger,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reservations.length,
                          itemBuilder: (_, i) =>
                              _ReservationCard(reservation: _reservations[i]),
                        ),
                      ),
              ],
            ),
    );
  }
}
 
// Carte d'une visite
class _VisiteCard extends StatelessWidget {
  final Visite visite;
  const _VisiteCard({required this.visite});
 
  @override
  Widget build(BuildContext context) {
    final statutConfig = {
      StatutVisite.enAttente: {'color': Colors.orange, 'label': 'En attente', 'icon': Icons.hourglass_empty},
      StatutVisite.acceptee: {'color': ImmoFasoTheme.success, 'label': 'Acceptée ✓', 'icon': Icons.check_circle},
      StatutVisite.refusee: {'color': Colors.red, 'label': 'Refusée', 'icon': Icons.cancel},
    };
    final conf = statutConfig[visite.statut]!;
 
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(visite.bienTitre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (conf['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(conf['icon'] as IconData,
                          color: conf['color'] as Color, size: 13),
                      const SizedBox(width: 4),
                      Text(conf['label'] as String,
                          style: TextStyle(
                              color: conf['color'] as Color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: ImmoFasoTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR').format(visite.dateVisite),
                  style: const TextStyle(fontSize: 13, color: ImmoFasoTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
 
// Carte d'une réservation
class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  const _ReservationCard({required this.reservation});
  
  // ignore: strict_top_level_inference, non_constant_identifier_names
  get ReservationService => null;
 
  @override
  Widget build(BuildContext context) {
    final statutConfig = {
      StatutReservation.enAttente: {'color': Colors.orange, 'label': 'En attente'},
      StatutReservation.confirmee: {'color': ImmoFasoTheme.success, 'label': 'Confirmée ✓'},
      StatutReservation.annulee: {'color': Colors.red, 'label': 'Annulée'},
    };
    final conf = statutConfig[reservation.statut]!;
 
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(reservation.bienTitre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (conf['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(conf['label'] as String,
                      style: TextStyle(
                          color: conf['color'] as Color,
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range, size: 14, color: ImmoFasoTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('d MMM', 'fr_FR').format(reservation.dateDebut)} → '
                  '${DateFormat('d MMM yyyy', 'fr_FR').format(reservation.dateFin)} '
                  '(${reservation.nombreJours} nuits)',
                  style: const TextStyle(fontSize: 13, color: ImmoFasoTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatPrix(reservation.montantTotal),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ImmoFasoTheme.primary,
                      fontSize: 16),
                ),
                if (reservation.statut == StatutReservation.enAttente)
                  TextButton.icon(
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Annuler'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () async {
                      await ReservationService.annuler(reservation.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}