import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


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
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier le profil',
            onPressed: () => _ouvrirModification(context, user, auth),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmerDeconnexion(context, auth),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header profil ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar — selfie ou initiale
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: HerressoTheme.primary,
                        backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                            ? NetworkImage('${ApiService.baseUrl.replaceAll('/api', '')}/storage/${user.avatar}')
                            : null,
                        child: user.avatar == null || user.avatar!.isEmpty
                            ? Text(
                                user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => _ouvrirModification(context, user, auth),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: HerressoTheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Menu ──
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _menuItem(icon: Icons.person_outline, label: 'Modifier mon profil', onTap: () => _ouvrirModification(context, user, auth)),
                  if (user.role == RoleUtilisateur.locataire) ...[
                    _menuItem(icon: Icons.calendar_today_outlined, label: 'Mes visites', onTap: () {}, badge: '2'),
                    _menuItem(icon: Icons.bookmark_outline, label: 'Réservations', onTap: () {}),
                    /*_menuItem(icon: Icons.description_outlined, label: 'Mes contrats', onTap: () {}), */
                  ],
                  if (user.role == RoleUtilisateur.proprietaire) ...[
                    _menuItem(
                      icon: Icons.home_outlined,
                      label: 'Mes annonces',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Mes annonces')), body: const Center(child: Text('Mes annonces')))),
                      ),
                    ),
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
                ],
              ),
            ),

            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              child: _menuItem(icon: Icons.logout, label: 'Se déconnecter', color: Colors.red, onTap: () => _confirmerDeconnexion(context, auth)),
            ),

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

// ════════════════════════════════════════
// MODIFIER PROFIL
// ════════════════════════════════════════
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
            const SizedBox(height: 8),

            // ── Infos du compte (lecture seule) ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informations du compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  _infoLigne('Nom', widget.user.nom),
                  _infoLigne('Prénom', widget.user.prenom),
                  if (widget.user.email.isNotEmpty) _infoLigne('Email', widget.user.email),
                  if (widget.user.telephone.isNotEmpty) _infoLigne('Téléphone', widget.user.telephone),
                  _infoLigne('Rôle', widget.user.role == RoleUtilisateur.locataire ? 'Locataire' : 'Propriétaire'),
                  _infoLigne('Membre depuis', DateFormat('MMMM yyyy', 'fr_FR').format(widget.user.dateCreation)),
                ],
              ),
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
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), helperText: 'L\'email ne peut pas être modifié'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined)),
            ),
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

  Widget _infoLigne(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: HerressoTheme.textSecondary, fontSize: 13))),
        Expanded(child: Text(valeur.isNotEmpty ? valeur : '—', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      ]),
    );
  }
}

// ════════════════════════════════════════
// PUBLIER UN BIEN
// ════════════════════════════════════════
class _PublierBienSheet extends StatefulWidget {
  const _PublierBienSheet();
  @override
  State<_PublierBienSheet> createState() => _PublierBienSheetState();
}

class _PublierBienSheetState extends State<_PublierBienSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _secteurCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _chambresCtrl = TextEditingController();
  final _sallesDeBainCtrl = TextEditingController();

  TypeLocation _typeLocation = TypeLocation.longTerme;
  TypeBien _typeBien = TypeBien.logement;
  bool _hasEau = true;
  bool _hasElec = true;
  bool _climatisation = false;
  bool _wifi = false;
  bool _parking = false;
  bool _isLoading = false;
  String? _erreur;

  final List<File> _photos = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    _villeCtrl.dispose();
    _secteurCtrl.dispose();
    _quartierCtrl.dispose();
    _chambresCtrl.dispose();
    _sallesDeBainCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: HerressoTheme.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (image != null) setState(() => _photos.add(File(image.path)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: HerressoTheme.primary),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (image != null) setState(() => _photos.add(File(image.path)));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _retirerPhoto(int index) => setState(() => _photos.removeAt(index));

  Future<void> _publier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _erreur = null; });

    final provider = context.read<ProprietaireProvider>();
    final ok = await provider.publierBien(
      titre: _titreCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      ville: _villeCtrl.text.trim(),
      secteur: _secteurCtrl.text.trim(),
      quartier: _quartierCtrl.text.trim(),
      prix: double.tryParse(_prixCtrl.text.trim()) ?? 0,
      typeLocation: _typeLocation == TypeLocation.sejour ? 'sejour' : 'long_terme',
      typeBien: _typeBien == TypeBien.localCommercial ? 'local_commercial' : 'logement',
      nombreChambres: int.tryParse(_chambresCtrl.text.trim()) ?? 0,
      nombreSallesDeBain: int.tryParse(_sallesDeBainCtrl.text.trim()) ?? 0,
      climatisation: _climatisation,
      wifi: _wifi,
      parking: _parking,
      eau: _hasEau,
      electricite: _hasElec,
      photos: _photos.isEmpty ? null : _photos,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bien publié !'), backgroundColor: HerressoTheme.primary),
      );
    } else {
      setState(() {
        _isLoading = false;
        _erreur = provider.erreur ?? 'Impossible de publier ce bien.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      builder: (ctx, ctrl) => Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text('Publier une annonce', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Photos ──
                    const Text('Photos', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._photos.asMap().entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(entry.value, width: 90, height: 90, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 2, right: 2,
                                      child: GestureDetector(
                                        onTap: () => _retirerPhoto(entry.key),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          GestureDetector(
                            onTap: _choisirPhoto,
                            child: Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: HerressoTheme.primary),
                                  SizedBox(height: 4),
                                  Text('Ajouter', style: TextStyle(fontSize: 11, color: HerressoTheme.primary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Type de bien', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: FilterChipWidget(label: 'Logement', isSelected: _typeBien == TypeBien.logement, onTap: () => setState(() => _typeBien = TypeBien.logement))),
                      const SizedBox(width: 8),
                      Expanded(child: FilterChipWidget(label: 'Local commercial', isSelected: _typeBien == TypeBien.localCommercial, onTap: () => setState(() => _typeBien = TypeBien.localCommercial))),
                    ]),
                    const SizedBox(height: 16),

                    const Text('Durée de location', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: FilterChipWidget(label: 'Long terme', isSelected: _typeLocation == TypeLocation.longTerme, onTap: () => setState(() => _typeLocation = TypeLocation.longTerme))),
                      const SizedBox(width: 8),
                      Expanded(child: FilterChipWidget(label: 'Séjour', isSelected: _typeLocation == TypeLocation.sejour, onTap: () => setState(() => _typeLocation = TypeLocation.sejour))),
                    ]),
                    const SizedBox(height: 16),

                    TextFormField(controller: _titreCtrl, decoration: const InputDecoration(labelText: 'Titre du bien *'), validator: (v) => v == null || v.isEmpty ? 'Titre requis' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description *'), validator: (v) => v == null || v.isEmpty ? 'Description requise' : null),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prixCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: _typeLocation == TypeLocation.sejour ? 'Prix par nuit (FCFA) *' : 'Loyer mensuel (FCFA) *'),
                      validator: (v) => v == null || v.isEmpty ? 'Prix requis' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(child: TextFormField(controller: _villeCtrl, decoration: const InputDecoration(labelText: 'Ville *'), validator: (v) => v == null || v.isEmpty ? 'Requis' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _secteurCtrl, decoration: const InputDecoration(labelText: 'Secteur *'), validator: (v) => v == null || v.isEmpty ? 'Requis' : null)),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(controller: _quartierCtrl, decoration: const InputDecoration(labelText: 'Quartier *'), validator: (v) => v == null || v.isEmpty ? 'Quartier requis' : null),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: _chambresCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Chambres *'),
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(
                        controller: _sallesDeBainCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Salles de bain *'),
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      )),
                    ]),
                    const SizedBox(height: 16),

                    const Text('Équipements', style: TextStyle(fontWeight: FontWeight.w600)),
                    Wrap(
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(value: _hasEau, onChanged: (v) => setState(() => _hasEau = v!), activeColor: HerressoTheme.primary),
                          const Text('Eau'),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(value: _hasElec, onChanged: (v) => setState(() => _hasElec = v!), activeColor: HerressoTheme.primary),
                          const Text('Électricité'),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(value: _climatisation, onChanged: (v) => setState(() => _climatisation = v!), activeColor: HerressoTheme.primary),
                          const Text('Climatisation'),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(value: _wifi, onChanged: (v) => setState(() => _wifi = v!), activeColor: HerressoTheme.primary),
                          const Text('Wifi'),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(value: _parking, onChanged: (v) => setState(() => _parking = v!), activeColor: HerressoTheme.primary),
                          const Text('Parking'),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_erreur != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_erreur!, style: const TextStyle(color: Colors.red))),
                        ]),
                      ),

                    PrimaryButton(
                      label: 'Publier le bien',
                      isLoading: _isLoading,
                      onPressed: _publier,
                      icon: Icons.publish,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}