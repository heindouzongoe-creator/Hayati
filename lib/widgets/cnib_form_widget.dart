import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cnib_scanner_service.dart';
import '../theme.dart';

class CnibFormWidget extends StatefulWidget {
  /// Appelé quand les infos CNIB changent
  final ValueChanged<CnibFormData> onChanged;

  const CnibFormWidget({super.key, required this.onChanged});

  @override
  State<CnibFormWidget> createState() => _CnibFormWidgetState();
}

class CnibFormData {
  final String numero;
  final String nom;
  final String prenom;
  final String dateNaissance;
  final String lieuNaissance;
  final String dateExpiration;
  final File? photoCnib;

  CnibFormData({
    required this.numero,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.dateExpiration,
    this.photoCnib,
  });
}

class _CnibFormWidgetState extends State<CnibFormWidget> {
  final _numeroCtrl      = TextEditingController();
  final _nomCtrl         = TextEditingController();
  final _prenomCtrl      = TextEditingController();
  final _dateNaissCtrl   = TextEditingController();
  final _lieuNaissCtrl   = TextEditingController();
  final _dateExpirCtrl   = TextEditingController();

  File? _photoCnib;
  bool _scanning = false;
  bool _scanFait = false;

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _dateNaissCtrl.dispose();
    _lieuNaissCtrl.dispose();
    _dateExpirCtrl.dispose();
    super.dispose();
  }

  void _notifier() {
    widget.onChanged(CnibFormData(
      numero: _numeroCtrl.text,
      nom: _nomCtrl.text,
      prenom: _prenomCtrl.text,
      dateNaissance: _dateNaissCtrl.text,
      lieuNaissance: _lieuNaissCtrl.text,
      dateExpiration: _dateExpirCtrl.text,
      photoCnib: _photoCnib,
    ));
  }

  Future<void> _prendrePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;

    final photo = File(picked.path);
    setState(() {
      _photoCnib = photo;
      _scanning = true;
      _scanFait = false;
    });

    try {
      final info = await CnibScannerService.scanner(photo);

      setState(() {
        if (info.numero != null) _numeroCtrl.text = info.numero!;
        if (info.nom != null) _nomCtrl.text = info.nom!;
        if (info.prenom != null) _prenomCtrl.text = info.prenom!;
        if (info.dateNaissance != null) _dateNaissCtrl.text = info.dateNaissance!;
        if (info.lieuNaissance != null) _lieuNaissCtrl.text = info.lieuNaissance!;
        if (info.dateExpiration != null) _dateExpirCtrl.text = info.dateExpiration!;
        _scanning = false;
        _scanFait = true;
      });

      _notifier();

      if (info.estVide && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan incomplet — vérifiez la photo et complétez manuellement'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du scan — remplissez manuellement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Titre ──
        const Text(
          'Informations CNIB *',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 4),
        const Text(
          'Prenez une photo de votre CNIB — les champs se rempliront automatiquement',
          style: TextStyle(color: HerressoTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),

        // ── Zone photo ──
        GestureDetector(
          onTap: () => _afficherChoixSource(),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: _photoCnib != null ? Colors.transparent : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _photoCnib != null ? HerressoTheme.primary : Colors.grey.shade300,
                width: _photoCnib != null ? 2 : 1,
              ),
            ),
            child: _photoCnib != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(_photoCnib!, width: double.infinity, height: 160, fit: BoxFit.cover),
                      ),
                      // Overlay scanning
                      if (_scanning)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 12),
                                Text('Lecture en cours...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      // Badge succès
                      if (_scanFait && !_scanning)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Scan réussi', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      // Bouton modifier
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _afficherChoixSource,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, size: 16, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Photographier la CNIB', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Les infos se rempliront automatiquement', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Champs CNIB ──
        _champCnib(
          ctrl: _numeroCtrl,
          label: 'Numéro CNIB',
          icone: Icons.badge_outlined,
          hint: 'ex: B1234567',
          majuscule: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _champCnib(ctrl: _nomCtrl, label: 'Nom', icone: Icons.person_outline, majuscule: true)),
            const SizedBox(width: 12),
            Expanded(child: _champCnib(ctrl: _prenomCtrl, label: 'Prénom', icone: Icons.person_outline)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _champCnib(ctrl: _dateNaissCtrl, label: 'Date de naissance', icone: Icons.cake_outlined, hint: 'jj/mm/aaaa')),
            const SizedBox(width: 12),
            Expanded(child: _champCnib(ctrl: _dateExpirCtrl, label: 'Date d\'expiration', icone: Icons.event_outlined, hint: 'jj/mm/aaaa')),
          ],
        ),
        const SizedBox(height: 12),
        _champCnib(
          ctrl: _lieuNaissCtrl,
          label: 'Lieu de naissance',
          icone: Icons.location_on_outlined,
          hint: 'ex: Ouagadougou',
        ),
      ],
    );
  }

  Widget _champCnib({
    required TextEditingController ctrl,
    required String label,
    required IconData icone,
    String? hint,
    bool majuscule = false,
  }) {
    return TextFormField(
      controller: ctrl,
      textCapitalization: majuscule ? TextCapitalization.characters : TextCapitalization.words,
      onChanged: (_) => _notifier(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icone, size: 20),
        filled: _scanFait,
        fillColor: _scanFait && ctrl.text.isNotEmpty ? Colors.green.shade50 : null,
      ),
      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
    );
  }

  void _afficherChoixSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Photographier la CNIB', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              onTap: () { Navigator.pop(ctx); _prendrePhoto(ImageSource.camera); },
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: HerressoTheme.primary.withValues( alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.camera_alt, color: HerressoTheme.primary)),
              title: const Text('Prendre une photo',style: TextStyle(fontWeight: FontWeight.w500,),),
              subtitle: const Text('Meilleure qualité pour le scan'),
            ),
            ListTile(
              onTap: () { Navigator.pop(ctx); _prendrePhoto(ImageSource.gallery); },
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: Icon(Icons.photo_library, color: Colors.blue.shade600)),
             title: const Text('Choisir depuis la galerie',style: TextStyle( fontWeight: FontWeight.w500,),),
              subtitle: const Text('Photo existante'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}