
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
//import '../services/http_service.dart';
 
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
 
  @override
  State<KycScreen> createState() => _KycScreenState();
}
 
class _KycScreenState extends State<KycScreen> {
  File? _cniRecto;
  File? _cniVerso;
  File? _selfie;
  final _nomCtrl = TextEditingController();
  final _cniNumCtrl = TextEditingController();
  bool _isLoading = false;
  String _statut = 'non_verifie'; // non_verifie, en_attente, verifie, rejete
 
  final _picker = ImagePicker();
 
  Future<void> _pickImage(String type) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;
    setState(() {
      switch (type) {
        case 'recto':  _cniRecto = File(picked.path); break;
        case 'verso':  _cniVerso = File(picked.path); break;
        case 'selfie': _selfie = File(picked.path); break;
      }
    });
  }
 
  Future<void> _soumettre() async {
    if (_cniRecto == null || _cniVerso == null || _selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez fournir tous les documents')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
     /* await HttpService.postMultipart(
        '/kyc/soumettre',
        fields: {
          'nom_complet': _nomCtrl.text,
          'numero_cni': _cniNumCtrl.text,
        },
        files: [
          MapEntry('cni_recto', _cniRecto!),
          MapEntry('cni_verso', _cniVerso!),
          MapEntry('selfie', _selfie!),
        ],
      );*/
      setState(() => _statut = 'en_attente');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documents soumis. Vérification sous 24h.'),
            backgroundColor: ImmoFasoTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification du compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statut actuel
            _buildStatutBanner(),
            const SizedBox(height: 24),
 
            if (_statut == 'non_verifie' || _statut == 'rejete') ...[
              const Text(
                'Pourquoi se vérifier ?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _infoItem(Icons.security, 'Inspirer confiance aux locataires'),
              _infoItem(Icons.star, 'Badge "Bailleur vérifié" sur vos annonces'),
              _infoItem(Icons.visibility, 'Annonces mieux référencées'),
              const SizedBox(height: 24),
 
              const Text(
                'Documents requis',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
 
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom complet (comme sur la CNI)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cniNumCtrl,
                decoration: const InputDecoration(
                  labelText: 'Numéro CNI / Passeport',
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 16),
 
              // Photos documents
              Row(
                children: [
                  Expanded(child: _photoBox('recto', 'CNI Recto', _cniRecto)),
                  const SizedBox(width: 12),
                  Expanded(child: _photoBox('verso', 'CNI Verso', _cniVerso)),
                ],
              ),
              const SizedBox(height: 12),
              _photoBox('selfie', 'Selfie avec votre CNI', _selfie,
                  fullWidth: true),
              const SizedBox(height: 24),
 
              PrimaryButton(
                label: 'Soumettre pour vérification',
                isLoading: _isLoading,
                onPressed: _soumettre,
                icon: Icons.verified_user_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
 
  Widget _buildStatutBanner() {
    final configs = {
      'non_verifie': {
        'color': Colors.orange,
        'icon': Icons.info_outline,
        'text': 'Compte non vérifié',
        'sub': 'Soumettez vos documents pour obtenir le badge vérifié',
      },
      'en_attente': {
        'color': Colors.blue,
        'icon': Icons.hourglass_empty,
        'text': 'Vérification en cours',
        'sub': 'Votre dossier est en cours d\'examen (24-48h)',
      },
      'verifie': {
        'color': ImmoFasoTheme.success,
        'icon': Icons.verified,
        'text': 'Compte vérifié ✓',
        'sub': 'Votre identité a été confirmée',
      },
      'rejete': {
        'color': Colors.red,
        'icon': Icons.cancel_outlined,
        'text': 'Vérification rejetée',
        'sub': 'Documents non conformes. Veuillez resoumettre.',
      },
    };
    final c = configs[_statut]!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (c['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (c['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(c['icon'] as IconData, color: c['color'] as Color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['text'] as String,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: c['color'] as Color)),
                Text(c['sub'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: ImmoFasoTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _infoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: ImmoFasoTheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
 
  Widget _photoBox(String type, String label, File? file,
      {bool fullWidth = false}) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        height: fullWidth ? 120 : 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null
                ? ImmoFasoTheme.success
                : ImmoFasoTheme.border,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(file, fit: BoxFit.cover,
                    width: double.infinity),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: ImmoFasoTheme.textLight, size: 30),
                  const SizedBox(height: 4),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: ImmoFasoTheme.textSecondary),
                      textAlign: TextAlign.center),
                ],
              ),
      ),
    );
  }
}
