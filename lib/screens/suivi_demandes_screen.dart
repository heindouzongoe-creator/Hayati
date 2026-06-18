import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _charger();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    setState(() => _isLoading = true);
    try {
      final resVisites = await ApiService.getMesVisites();
      final resReservations = await ApiService.getMesReservations();
      setState(() {
        _visites = (resVisites['data'] as List).map((v) => Visite.fromJson(v)).toList();
        _reservations = (resReservations['data'] as List).map((r) => Reservation.fromJson(r)).toList();
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
          ? const Center(child: CircularProgressIndicator(color: HerressoTheme.primary))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                // ── Visites ──
                _visites.isEmpty
                    ? const EmptyState(icon: Icons.calendar_today_outlined, title: 'Aucune visite demandée')
                    : RefreshIndicator(
                        onRefresh: _charger,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _visites.length,
                          itemBuilder: (_, i) => _VisiteCard(visite: _visites[i], onAnnuler: _charger),
                        ),
                      ),

                // ── Réservations ──
                _reservations.isEmpty
                    ? const EmptyState(icon: Icons.bookmark_outline, title: 'Aucune réservation')
                    : RefreshIndicator(
                        onRefresh: _charger,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reservations.length,
                          itemBuilder: (_, i) => _ReservationCard(reservation: _reservations[i], onAnnuler: _charger),
                        ),
                      ),
              ],
            ),
    );
  }
}

// ── Carte Visite ──
class _VisiteCard extends StatelessWidget {
  final Visite visite;
  final VoidCallback onAnnuler;
  const _VisiteCard({required this.visite, required this.onAnnuler});

  @override
  Widget build(BuildContext context) {
    final conf = {
      StatutVisite.enAttente: {'color': Colors.orange, 'label': 'En attente',  'icon': Icons.hourglass_empty},
      StatutVisite.confirme:  {'color': HerressoTheme.success, 'label': 'Confirmée ✓', 'icon': Icons.check_circle},
      StatutVisite.refuse:    {'color': Colors.red,    'label': 'Refusée',     'icon': Icons.cancel},
      StatutVisite.annule:    {'color': Colors.grey,   'label': 'Annulée',     'icon': Icons.block},
    }[visite.statut]!;

    final bienTitre = visite.bien?.titre ?? 'Bien #${visite.bienId}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(bienTitre, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: (conf['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(conf['icon'] as IconData, color: conf['color'] as Color, size: 13),
                const SizedBox(width: 4),
                Text(conf['label'] as String, style: TextStyle(color: conf['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today, size: 14, color: HerressoTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(visite.dateVisite)} à ${visite.heureVisite}',
              style: const TextStyle(fontSize: 13, color: HerressoTheme.textSecondary),
            ),
          ]),
          if (visite.message != null) ...[
            const SizedBox(height: 6),
            Text(visite.message!, style: const TextStyle(fontSize: 12, color: HerressoTheme.textSecondary)),
          ],
        ]),
      ),
    );
  }
}

// ── Carte Réservation ──
class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onAnnuler;
  const _ReservationCard({required this.reservation, required this.onAnnuler});

  @override
  Widget build(BuildContext context) {
    final conf = {
      StatutReservation.enAttente: {'color': Colors.orange, 'label': 'En attente'},
      StatutReservation.confirme:  {'color': HerressoTheme.success, 'label': 'Confirmée ✓'},
      StatutReservation.annule:    {'color': Colors.red, 'label': 'Annulée'},
    }[reservation.statut]!;

    final bienTitre = reservation.bien?.titre ?? 'Bien #${reservation.bienId}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(bienTitre, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: (conf['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(conf['label'] as String, style: TextStyle(color: conf['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.date_range, size: 14, color: HerressoTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${DateFormat('d MMM', 'fr_FR').format(reservation.dateDebut)} → ${DateFormat('d MMM yyyy', 'fr_FR').format(reservation.dateFin)} (${reservation.nombreJours} nuits)',
              style: const TextStyle(fontSize: 13, color: HerressoTheme.textSecondary),
            ),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(formatPrix(reservation.montantTotal), style: const TextStyle(fontWeight: FontWeight.bold, color: HerressoTheme.primary, fontSize: 16)),
            if (reservation.statut == StatutReservation.enAttente)
              TextButton.icon(
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Annuler'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ApiService.annulerReservation(reservation.id);
                    onAnnuler();
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
          ]),
        ]),
      ),
    );
  }
}