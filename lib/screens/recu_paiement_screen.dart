
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
 
class RecuPaiementScreen extends StatelessWidget {
  final Map<String, dynamic> paiement;
 
  const RecuPaiementScreen({super.key, required this.paiement});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçu de paiement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Partager le reçu (Share.share())
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // En-tête reçu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ImmoFasoTheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 60),
                  const SizedBox(height: 12),
                  const Text('Paiement réussi',
                      style: TextStyle(color: Colors.white,
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    formatPrix((paiement['montant'] as num).toDouble()),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
 
            // Détails du reçu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                children: [
                  _ligneRecu('Référence', paiement['transaction_id'] ?? 'N/A'),
                  const Divider(),
                  _ligneRecu('Type', _formatType(paiement['type'] ?? '')),
                  _ligneRecu('Mode', _formatMode(paiement['mode_paiement'] ?? '')),
                  _ligneRecu('Statut', 'Validé ✓', valueColor: ImmoFasoTheme.success),
                  _ligneRecu('Date', paiement['date_paiement'] ?? ''),
                  const Divider(),
                  _ligneRecu(
                    'Montant total',
                    formatPrix((paiement['montant'] as num).toDouble()),
                    isBold: true,
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 24),
 
            // Mention légale
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Ce reçu constitue une preuve de paiement valide. '
                'Conservez-le pour vos archives.\n'
                'ImmoFaso - Plateforme de location - Burkina Faso',
                style: TextStyle(fontSize: 11, color: ImmoFasoTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
 
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Fermer',
              onPressed: () => Navigator.pop(context),
              color: ImmoFasoTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _ligneRecu(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: ImmoFasoTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? ImmoFasoTheme.textPrimary,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
 
  String _formatType(String type) {
    const map = {
      'loyer': 'Loyer mensuel',
      'prix': 'Loyer journalier',
      'caution': 'Caution',
      'avance': 'Avance',
      'reservation': 'Réservation',
      'visite': 'Frais de visite',
    };
    return map[type] ?? type;
  }
 
  String _formatMode(String mode) {
    const map = {
      'orange_money': 'Orange Money',
      'moov_money': 'Moov Money',
      'coris_money': 'Coris Money',
      'cash': 'Espèces',
      'virement': 'Virement',
    };
    return map[mode] ?? mode;
  }
}
