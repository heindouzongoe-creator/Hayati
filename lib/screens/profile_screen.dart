import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final Function(Bien) onBienTap;

  const ProfileScreen({super.key, required this.onLogout, required this.onBienTap});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon profil')),
        body: EmptyState(
          icon: Icons.person_outline,
          title: 'Non connecté',
          subtitle: 'Connectez-vous pour accéder à votre profil',
          buttonLabel: 'Se connecter',
          onButton: onLogout,
        ),
      );
    }

    final user = auth.currentUser!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _ouvrirModification(context, user, auth)),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _confirmerDeconnexion(context, auth)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Stack(children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: HerressoTheme.primary,
                    backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                        ? NetworkImage('${ApiService.baseUrl.replaceAll('/api', '')}/storage/${user.avatar}')
                        : null,
                    child: user.avatar == null || user.avatar!.isEmpty
                        ? Text(user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  Positioned(bottom: 0, right: 0, child: GestureDetector(
                    onTap: () => _ouvrirModification(context, user, auth),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: HerressoTheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  )),
                ]),
                const SizedBox(height: 12),
                Text(user.nomComplet, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(color: HerressoTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    user.role == RoleUtilisateur.locataire ? 'Locataire' : 'Propriétaire',
                    style: const TextStyle(color: HerressoTheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: Column(children: [
                _menuItem(icon: Icons.person_outline, label: 'Modifier mon profil', onTap: () => _ouvrirModification(context, user, auth)),
                if (user.role == RoleUtilisateur.locataire) ...[
                  _menuItem(icon: Icons.calendar_today_outlined, label: 'Mes visites', onTap: () {}, badge: '2'),
                  _menuItem(icon: Icons.bookmark_outline, label: 'Réservations', onTap: () {}),
                ],
                if (user.role == RoleUtilisateur.proprietaire) ...[
                  _menuItem(icon: Icons.home_outlined, label: 'Mes annonces', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Mes annonces')), body: const Center(child: Text('Mes annonces')))))),
                  _menuItem(
                    icon: Icons.add_home_outlined,
                    label: 'Publier un bien',
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => const _PublierBienSheet(),
                    ),
                  ),
                ],
                _menuItem(icon: Icons.payment_outlined, label: 'Historique paiements', onTap: () {}),
                _menuItem(icon: Icons.help_outline, label: 'Aide & Support', onTap: () {}),
                _menuItem(icon: Icons.info_outline, label: "À propos d'Herresso", onTap: () {}),
              ]),
            ),
            const SizedBox(height: 8),
            Container(color: Colors.white, child: _menuItem(icon: Icons.logout, label: 'Se déconnecter', color: Colors.red, onTap: () => _confirmerDeconnexion(context, auth))),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String label, required VoidCallback onTap, String? badge, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? HerressoTheme.primary),
      title: Text(label, style: TextStyle(color: color ?? HerressoTheme.textPrimary, fontWeight: FontWeight.w500)),
      trailing: badge != null
          ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: HerressoTheme.primary, borderRadius: BorderRadius.circular(10)), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11)))
          : const Icon(Icons.chevron_right, color: HerressoTheme.textLight),
      onTap: onTap,
    );
  }

  void _confirmerDeconnexion(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); auth.logout(); onLogout(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  void _ouvrirModification(BuildContext context, Utilisateur user, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ModifierProfilSheet(user: user, auth: auth),
    );
  }
}


// MODIFIER PROFIL

class _ModifierProfilSheet extends StatefulWidget {
  final Utilisateur user;
  final AuthProvider auth;
  const _ModifierProfilSheet({required this.user, required this.auth});
  @override
  State<_ModifierProfilSheet> createState() => _ModifierProfilSheetState();
}

class _ModifierProfilSheetState extends State<_ModifierProfilSheet> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telCtrl;
  bool _isLoading = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _nomCtrl    = TextEditingController(text: widget.user.nom);
    _prenomCtrl = TextEditingController(text: widget.user.prenom);
    _emailCtrl  = TextEditingController(text: widget.user.email);
    _telCtrl    = TextEditingController(text: widget.user.telephone);
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _emailCtrl.dispose(); _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    setState(() { _isLoading = true; _erreur = null; });
    try {
      await ApiService.updateProfil(nom: _nomCtrl.text.trim(), prenom: _prenomCtrl.text.trim(), telephone: _telCtrl.text.trim());
      await widget.auth.reloadUser();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Colors.green));
      }
    } on ApiException catch (e) {
      setState(() { _erreur = e.message; _isLoading = false; });
    } catch (_) {
      setState(() { _erreur = 'Erreur de connexion'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Modifier mon profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Informations du compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _infoLigne('Nom', widget.user.nom),
                _infoLigne('Prénom', widget.user.prenom),
                if (widget.user.email.isNotEmpty) _infoLigne('Email', widget.user.email),
                if (widget.user.telephone.isNotEmpty) _infoLigne('Téléphone', widget.user.telephone),
                _infoLigne('Rôle', widget.user.role == RoleUtilisateur.locataire ? 'Locataire' : 'Propriétaire'),
                _infoLigne('Membre depuis', DateFormat('MMMM yyyy', 'fr_FR').format(widget.user.dateCreation)),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Modifier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _nomCtrl, decoration: const InputDecoration(labelText: 'Nom'), textCapitalization: TextCapitalization.characters)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _prenomCtrl, decoration: const InputDecoration(labelText: 'Prénom'))),
            ]),
            const SizedBox(height: 16),
            TextFormField(controller: _emailCtrl, enabled: false, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), helperText: 'L\'email ne peut pas être modifié')),
            const SizedBox(height: 16),
            TextFormField(controller: _telCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 24),
            if (_erreur != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text(_erreur!, style: const TextStyle(color: Colors.red)))]),
              ),
            PrimaryButton(label: 'Sauvegarder', onPressed: _sauvegarder, isLoading: _isLoading, icon: Icons.save_outlined),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoLigne(String label, String valeur) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(color: HerressoTheme.textSecondary, fontSize: 13))),
      Expanded(child: Text(valeur.isNotEmpty ? valeur : '—', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
    ]),
  );
}


// PUBLIER UN BIEN

class _PublierBienSheet extends StatefulWidget {
  const _PublierBienSheet();
  @override
  State<_PublierBienSheet> createState() => _PublierBienSheetState();
}

class _PublierBienSheetState extends State<_PublierBienSheet> {
  final _formKey      = GlobalKey<FormState>();
  final _titreCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _prixCtrl     = TextEditingController();
  final _secteurCtrl  = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _picker       = ImagePicker();

  // Étape active : 0=ville, 1=détails
  int _etape = 0;

  String? _typeLocation;
  String? _typeBien;
  String? _ville;
  bool   _villeAutre = false;
  final _villeAutreCtrl = TextEditingController();
  int    _chambres      = 1;
  int    _sallesDeBain  = 1;
  bool   _hasEau        = true;
  bool   _hasElec       = true;
  bool   _climatisation = false;
  bool   _wifi          = false;
  bool   _parking       = false;
  bool   _courCommune   = false;
  bool   _isLoading     = false;
  String? _erreur;

  final List<File>      _photos      = [];
  final List<Uint8List> _photosBytes = [];

  // ── Données ──
  static const _villes = [
    'Ouagadougou', 'Bobo-Dioulasso', 'Koudougou', 'Banfora', 'Ouahigouya',
  ];

  static const _typesBienParLocation = {
    'long_terme': [
      {'value': 'villa',            'label': 'Villa',            'icon': Icons.house},
      {'value': 'residence',        'label': 'Résidence',        'icon': Icons.apartment},
      {'value': 'chambre',          'label': 'Chambre',          'icon': Icons.bed},
      {'value': 'local_commercial', 'label': 'Local commercial', 'icon': Icons.store},
    ],
    'sejour': [
      {'value': 'auberge', 'label': 'Auberge', 'icon': Icons.hotel},
      {'value': 'hotel',   'label': 'Hôtel',   'icon': Icons.business},
      {'value': 'villa',   'label': 'Villa',   'icon': Icons.house},
      {'value': 'chambre', 'label': 'Chambre', 'icon': Icons.bed},
    ],
  };

  List<Map<String, dynamic>> get _typesBienDisponibles =>
      (_typesBienParLocation[_typeLocation] ?? []).cast<Map<String, dynamic>>();

  @override
  void dispose() {
    _titreCtrl.dispose(); _descCtrl.dispose(); _prixCtrl.dispose();
    _secteurCtrl.dispose(); _quartierCtrl.dispose(); _villeAutreCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    if (_photosBytes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 photos'), backgroundColor: Colors.orange));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Wrap(children: [
        ListTile(
          leading: const Icon(Icons.photo_library_outlined, color: HerressoTheme.primary),
          title: const Text('Choisir depuis la galerie'),
          onTap: () async {
            Navigator.pop(ctx);
            final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
            if (image == null) return;
            final bytes = await image.readAsBytes();
            setState(() { _photosBytes.add(bytes); if (!kIsWeb) _photos.add(File(image.path)); });
          },
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt_outlined, color: HerressoTheme.primary),
          title: const Text('Prendre une photo'),
          onTap: () async {
            Navigator.pop(ctx);
            final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
            if (image == null) return;
            final bytes = await image.readAsBytes();
            setState(() { _photosBytes.add(bytes); if (!kIsWeb) _photos.add(File(image.path)); });
          },
        ),
      ])),
    );
  }

  void _retirerPhoto(int index) {
    setState(() {
      _photosBytes.removeAt(index);
      if (!kIsWeb && index < _photos.length) _photos.removeAt(index);
    });
  }

  Future<void> _publier() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photosBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajoutez au moins une photo'), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; _erreur = null; });

    final provider = context.read<ProprietaireProvider>();
    final ok = await provider.publierBien(
      titre:              _titreCtrl.text.trim(),
      description:        _descCtrl.text.trim(),
      ville:              _ville!,
      secteur:            _secteurCtrl.text.trim(),
      quartier:           _quartierCtrl.text.trim(),
      prix:               double.tryParse(_prixCtrl.text.trim()) ?? 0,
      typeLocation:       _typeLocation!,
      typeBien:           _typeBien!,
      nombreChambres:     _chambres,
      nombreSallesDeBain: _sallesDeBain,
      climatisation:      _climatisation,
      wifi:               _wifi,
      parking:            _parking,
      eau:                _hasEau,
      electricite:        _hasElec,
      photos:             kIsWeb ? null : (_photos.isEmpty ? null : _photos),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bien publié !'), backgroundColor: Colors.green));
    } else {
      setState(() { _isLoading = false; _erreur = provider.erreur ?? 'Impossible de publier ce bien.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      builder: (ctx, ctrl) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(children: [
              _breadcrumb('Ville', _ville, actif: _etape == 0, onTap: () => setState(() => _etape = 0)),
              const Icon(Icons.chevron_right, size: 16, color: HerressoTheme.textLight),
              _breadcrumb('Détails', null, actif: _etape == 1, onTap: _ville != null ? () => setState(() => _etape = 1) : null),
            ]),
          ]),
        ),
        const Divider(height: 20),
        Expanded(
          child: SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: _etape == 0 ? _etapeVille() : _etapeDetails(),
          ),
        ),
      ]),
    );
  }

  // ── ÉTAPE 0 : Ville ──
  Widget _etapeVille() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Ville', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      const Text('Dans quelle ville se trouve le bien ?', style: TextStyle(color: HerressoTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 20),
      ..._villes.map((ville) {
        final selected = _ville == ville && !_villeAutre;
        return GestureDetector(
          onTap: () => setState(() { _ville = ville; _villeAutre = false; _etape = 1; }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: selected ? HerressoTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? HerressoTheme.primary : HerressoTheme.border, width: selected ? 2 : 1),
              boxShadow: selected ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Icon(Icons.location_on_outlined, color: selected ? Colors.white : HerressoTheme.primary, size: 22),
              const SizedBox(width: 16),
              Expanded(child: Text(ville, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: selected ? Colors.white : HerressoTheme.textPrimary))),
              Icon(Icons.arrow_forward_ios, size: 16, color: selected ? Colors.white70 : HerressoTheme.textLight),
            ]),
          ),
        );
      }),
      // Option "Autre ville"
      GestureDetector(
        onTap: () => setState(() { _villeAutre = true; _ville = null; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: _villeAutre ? HerressoTheme.primary.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _villeAutre ? HerressoTheme.primary : HerressoTheme.border, width: _villeAutre ? 2 : 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Icon(Icons.add_location_alt_outlined, color: HerressoTheme.primary, size: 22),
            const SizedBox(width: 16),
            const Expanded(child: Text('Autre ville', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: HerressoTheme.primary))),
            Icon(Icons.keyboard_arrow_down, size: 20, color: HerressoTheme.primary),
          ]),
        ),
      ),
      if (_villeAutre) ...[
        const SizedBox(height: 4),
        TextFormField(
          controller: _villeAutreCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom de la ville *', prefixIcon: Icon(Icons.edit_location_outlined)),
          onChanged: (v) => setState(() => _ville = v.trim().isEmpty ? null : v.trim()),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _ville != null ? () => setState(() => _etape = 1) : null,
            style: ElevatedButton.styleFrom(backgroundColor: HerressoTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Continuer'),
          ),
        ),
      ],
    ],
  );

  // ── ÉTAPE 1 : Détails ──
  Widget _etapeDetails() => Form(
    key: _formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Type de location + Type de bien (dropdowns)
      _sectionTitre('Type de location'),
      DropdownButtonFormField<String>(
        initialValue: _typeLocation,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_month_outlined)),
        hint: const Text('Sélectionner'),
        items: const [
          DropdownMenuItem(value: 'long_terme', child: Text('Long terme — mensuel / annuel')),
          DropdownMenuItem(value: 'sejour',     child: Text('Séjour — à la nuitée')),
        ],
        onChanged: (v) => setState(() { _typeLocation = v; _typeBien = null; }),
        validator: (v) => v == null ? 'Requis' : null,
      ),
      const SizedBox(height: 12),
      if (_typeLocation != null) ...[
        _sectionTitre('Type de bien'),
        DropdownButtonFormField<String>(
          initialValue: _typeBien,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.home_outlined)),
          hint: const Text('Sélectionner'),
          items: _typesBienDisponibles.map((item) => DropdownMenuItem(
            value: item['value'] as String,
            child: Row(children: [
              Icon(item['icon'] as IconData, size: 18, color: HerressoTheme.primary),
              const SizedBox(width: 8),
              Text(item['label'] as String),
            ]),
          )).toList(),
          onChanged: (v) => setState(() => _typeBien = v),
          validator: (v) => v == null ? 'Requis' : null,
        ),
        const SizedBox(height: 24),
      ],

      // Photos
      _sectionTitre('Photos', subtitle: 'Minimum 1, maximum 5'),
      _zonePhotos(),
      const SizedBox(height: 24),

      // Infos
      _sectionTitre('Informations générales'),
      TextFormField(controller: _titreCtrl, decoration: const InputDecoration(labelText: 'Titre du bien *', prefixIcon: Icon(Icons.title)), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
      const SizedBox(height: 12),
      TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description *', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
      const SizedBox(height: 12),
      TextFormField(
        controller: _prixCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: _typeLocation == 'sejour' ? 'Prix par nuit (FCFA) *' : 'Loyer mensuel (FCFA) *',
          prefixIcon: const Icon(Icons.payments_outlined),
          suffixText: 'FCFA',
        ),
        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
      ),
      const SizedBox(height: 24),

      // Localisation
      _sectionTitre('Localisation', subtitle: 'Ville : $_ville'),
      TextFormField(controller: _secteurCtrl, decoration: const InputDecoration(labelText: 'Secteur *', prefixIcon: Icon(Icons.map_outlined)), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
      const SizedBox(height: 12),
      TextFormField(controller: _quartierCtrl, decoration: const InputDecoration(labelText: 'Quartier *', prefixIcon: Icon(Icons.location_on_outlined)), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
      const SizedBox(height: 24),

      // Caractéristiques
      _sectionTitre('Caractéristiques'),
      Row(children: [
        Expanded(child: _compteur(label: 'Chambres', icone: Icons.bed_outlined, value: _chambres, onMoins: () { if (_chambres > 0) setState(() => _chambres--); }, onPlus: () => setState(() => _chambres++))),
        const SizedBox(width: 12),
        Expanded(child: _compteur(label: 'Salle de bain', icone: Icons.bathroom_outlined, value: _sallesDeBain, onMoins: () { if (_sallesDeBain > 0) setState(() => _sallesDeBain--); }, onPlus: () => setState(() => _sallesDeBain++))),
      ]),
      const SizedBox(height: 24),

      // Cour
      _sectionTitre('Type de cour'),
      Row(children: [
        Expanded(child: _toggleCard(label: 'Cour unique', icone: Icons.lock_outline, selected: !_courCommune, onTap: () => setState(() => _courCommune = false))),
        const SizedBox(width: 12),
        Expanded(child: _toggleCard(label: 'Cour commune', icone: Icons.people_outline, selected: _courCommune, onTap: () => setState(() => _courCommune = true))),
      ]),
      const SizedBox(height: 24),

      // Équipements
      _sectionTitre('Équipements & services'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _chip(label: 'Eau',           icone: Icons.water_drop_outlined, value: _hasEau,        onTap: () => setState(() => _hasEau = !_hasEau)),
        _chip(label: 'Électricité',   icone: Icons.bolt_outlined,       value: _hasElec,       onTap: () => setState(() => _hasElec = !_hasElec)),
        _chip(label: 'Climatisation', icone: Icons.ac_unit,             value: _climatisation, onTap: () => setState(() => _climatisation = !_climatisation)),
        _chip(label: 'Wifi',          icone: Icons.wifi,                value: _wifi,          onTap: () => setState(() => _wifi = !_wifi)),
        _chip(label: 'Parking',       icone: Icons.local_parking,       value: _parking,       onTap: () => setState(() => _parking = !_parking)),
      ]),
      const SizedBox(height: 24),

      if (_erreur != null)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
          child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text(_erreur!, style: const TextStyle(color: Colors.red)))]),
        ),

      PrimaryButton(label: 'Publier le bien', isLoading: _isLoading, onPressed: _publier, icon: Icons.publish),
      const SizedBox(height: 16),
    ]),
  );

  Widget _breadcrumb(String label, String? valeur, {required bool actif, VoidCallback? onTap}) {
    final couleur = actif ? HerressoTheme.primary : (valeur != null ? Colors.green : HerressoTheme.textLight);
    return GestureDetector(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: couleur, fontWeight: actif ? FontWeight.bold : FontWeight.normal)),
        if (valeur != null) Text(valeur, style: TextStyle(fontSize: 11, color: couleur, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _sectionTitre(String titre, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12, color: HerressoTheme.textSecondary)),
    ]),
  );

  Widget _zonePhotos() => Column(children: [
    if (_photosBytes.isNotEmpty) ...[
      SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _photosBytes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_photosBytes[i], width: 100, height: 100, fit: BoxFit.cover)),
            if (i == 0)
              Positioned(bottom: 4, left: 4, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: HerressoTheme.primary, borderRadius: BorderRadius.circular(4)),
                child: const Text('Principale', style: TextStyle(color: Colors.white, fontSize: 10)),
              )),
            Positioned(top: 4, right: 4, child: GestureDetector(
              onTap: () => _retirerPhoto(i),
              child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)),
            )),
          ]),
        ),
      ),
      const SizedBox(height: 8),
    ],
    if (_photosBytes.length < 5)
      GestureDetector(
        onTap: _choisirPhoto,
        child: Container(
          width: double.infinity, height: 70,
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_a_photo_outlined, color: HerressoTheme.primary),
            const SizedBox(width: 8),
            Text('Ajouter une photo (${_photosBytes.length}/5)', style: const TextStyle(color: HerressoTheme.primary, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
  ]);

  Widget _compteur({required String label, required IconData icone, required int value, required VoidCallback onMoins, required VoidCallback onPlus}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: HerressoTheme.border), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Row(children: [Icon(icone, size: 15, color: HerressoTheme.textSecondary), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 12, color: HerressoTheme.textSecondary))]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: onMoins, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.remove, size: 16))),
          Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          GestureDetector(onTap: onPlus, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: HerressoTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.add, size: 16, color: HerressoTheme.primary))),
        ]),
      ]),
    );
  }

  Widget _toggleCard({required String label, required IconData icone, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? HerressoTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? HerressoTheme.primary : HerressoTheme.border, width: selected ? 2 : 1),
        ),
        child: Column(children: [
          Icon(icone, size: 22, color: selected ? Colors.white : HerressoTheme.primary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : HerressoTheme.textPrimary)),
        ]),
      ),
    );
  }

  Widget _chip({required String label, required IconData icone, required bool value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: value ? HerressoTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: value ? HerressoTheme.primary : HerressoTheme.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icone, size: 16, color: value ? Colors.white : HerressoTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: value ? Colors.white : HerressoTheme.textSecondary)),
        ]),
      ),
    );
  }
}