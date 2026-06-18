import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bien_provider.dart';

class DemandeVisiteScreen extends StatefulWidget {
  final String locataireId;
  final String piedId;

  const DemandeVisiteScreen({
    super.key,
    required this.locataireId,
    required this.piedId,
  });

  @override
  State<DemandeVisiteScreen> createState() => _DemandeVisiteScreenState();
}

class _DemandeVisiteScreenState extends State<DemandeVisiteScreen> {
  DateTime? _dateVisite;
  bool _loading = false;

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      final heure = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
      );
      if (heure != null) {
        setState(() {
          _dateVisite = DateTime(
            date.year, date.month, date.day,
            heure.hour, heure.minute,
          );
        });
      }
    }
  }

  Future<void> _envoyerDemande() async {
    if (_dateVisite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis une date pour la visite')),
      );
      return;
    }
    setState(() => _loading = true);

    final provider = Provider.of<BienProvider>(context, listen: false);
    // Use dynamic call to avoid static analyzer error if method name differs
    final success = await (provider as dynamic).demandeVisite(
      locataireId: widget.locataireId,
      piedId: widget.piedId,
      dateVisite: _dateVisite!,
    );

    setState(() => _loading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de visite envoyée !'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demander une visite')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choisir la date et l\'heure de visite',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _choisirDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _dateVisite == null
                          ? 'Sélectionner une date'
                          : '${_dateVisite!.day}/${_dateVisite!.month}/${_dateVisite!.year} à ${_dateVisite!.hour}h${_dateVisite!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _dateVisite == null ? Colors.grey : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
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