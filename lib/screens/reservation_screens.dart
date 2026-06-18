import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DemandeReservationScreen extends StatefulWidget {
  final String locataireId;
  final String offreLocationId;

  const DemandeReservationScreen({
    super.key,
    required this.locataireId,
    required this.offreLocationId,
  });

  @override
  State<DemandeReservationScreen> createState() => _DemandeReservationScreenState();
}

class _DemandeReservationScreenState extends State<DemandeReservationScreen> {
  DateTime? _dateDebut;
  DateTime? _dateFin;
  final _messageController = TextEditingController();
  bool _loading = false;

  Future<void> _choisirDateDebut() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _dateDebut = date);
  }

  Future<void> _choisirDateFin() async {
    if (_dateDebut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis d\'abord la date de début')),
      );
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _dateDebut!.add(const Duration(days: 1)),
      firstDate: _dateDebut!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _dateFin = date);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner';
    return '${date.day}/${date.month}/${date.year}';
  }

  int get _nombreJours {
    if (_dateDebut == null || _dateFin == null) return 0;
    return _dateFin!.difference(_dateDebut!).inDays;
  }

  Future<void> _envoyerDemande() async {
    if (_dateDebut == null || _dateFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis les dates de début et fin')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await Provider.of(context, listen: false)
        .demanderReservation(
      locataireId: widget.locataireId,
      offreLocationId: widget.offreLocationId,
      dateDebut: _dateDebut!,
      dateFin: _dateFin!,
      message: _messageController.text.isNotEmpty ? _messageController.text : null,
    );

    setState(() => _loading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de réservation envoyée !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur, réessaie plus tard'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demander une réservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dates
            const Text(
              'Période de location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateCard(
                    label: 'Début',
                    value: _formatDate(_dateDebut),
                    onTap: _choisirDateDebut,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateCard(
                    label: 'Fin',
                    value: _formatDate(_dateFin),
                    onTap: _choisirDateFin,
                  ),
                ),
              ],
            ),

            // Résumé durée
            if (_nombreJours > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Durée : $_nombreJours jour${_nombreJours > 1 ? 's' : ''}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Message optionnel
            const Text(
              'Message au propriétaire (optionnel)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Présente-toi, explique ta situation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _loading ? null : _envoyerDemande,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Envoyer la demande',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}