// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'kyc_screen.dart';
//import 'recu_paiement_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final Function(Bien) onBienTap;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    required this.onBienTap,
  });

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
      backgroundColor: ImmoFasoTheme.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        auth.logout();
                        onLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Déconnecter'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header profil
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: ImmoFasoTheme.primary,
                    child: Text(
                      user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.nomComplet,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: ImmoFasoTheme.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role == RoleUtilisateur.locataire
                          ? '🏠 Locataire'
                          : user.role == RoleUtilisateur.proprietaire
                              ? '🏡 Propriétaire'
                              : '🏢 Agence',
                      style: const TextStyle(
                        color: ImmoFasoTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: ImmoFasoTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: ImmoFasoTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: ImmoFasoTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.telephone,
                        style: const TextStyle(color: ImmoFasoTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Notifications
            _buildNotifications(),

            const SizedBox(height: 8),

            // Options
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.person_outline,
                    label: 'Modifier mon profil',
                    onTap: () {},
                  ),
                  if (user.role == RoleUtilisateur.locataire) ...[
                    _menuItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Mes visites',
                      onTap: () {},
                      badge: '2',
                    ),
                    _menuItem(
                      icon: Icons.bookmark_outline,
                      label: 'Mes réservations',
                      onTap: () {},
                    ),
                    _menuItem(
                      icon: Icons.description_outlined,
                      label: 'Mes contrats',
                      onTap: () {},
                    ),
                  ],
                  if (user.role == RoleUtilisateur.proprietaire) ...[
                    _menuItem(
                      icon: Icons.home_outlined,
                      label: 'Mes biens',
                      onTap: () {},
                    ),
                    _menuItem(
                      icon: Icons.add_home_outlined,
                      label: 'Publier un bien',
                      onTap: () => _showPublierBien(context),
                    ),
                  ],
                  _menuItem(
                    icon: Icons.payment_outlined,
                    label: 'Historique paiements',
                    onTap: () {},
                  ),
                  _menuItem(
                     icon: Icons.verified_user_outlined,
                     label: 'Vérification du compte',
                      onTap: () {
                      Navigator.push(
                       context,
                        MaterialPageRoute(builder: (_) => const KycScreen()),
                    );
               },
       ),
                  _menuItem(
                    icon: Icons.help_outline,
                    label: 'Aide & Support',
                    onTap: () {},
                  ),
                  _menuItem(
                    icon: Icons.info_outline,
                    label: 'À propos d\'ImmoFaso',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Déconnexion
            Container(
              color: Colors.white,
              child: _menuItem(
                icon: Icons.logout,
                label: 'Se déconnecter',
                color: Colors.red,
                onTap: () {
                  auth.logout();
                  onLogout();
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    final notifs = [];
    final nonLues = notifs.where((n) => !n.estLu).length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              if (nonLues > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$nonLues',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...notifs.take(3).map(
            (n) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: n.estLu
                      ? Colors.grey.shade100
                      : ImmoFasoTheme.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: n.estLu ? Colors.grey : ImmoFasoTheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                n.message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: n.estLu ? FontWeight.normal : FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _formatDate(n.dateEnvoi),
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? ImmoFasoTheme.primary),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? ImmoFasoTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ImmoFasoTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            )
          : const Icon(Icons.chevron_right, color: ImmoFasoTheme.textLight),
      onTap: onTap,
    );
  }

  void _showPublierBien(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _PublierBienSheet(),
    );
  }
}

// ---- PUBLIER UN BIEN ----
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
  TypeLocation _typeLocation = TypeLocation.longTerme;
  TypeBien _typeBien = TypeBien.logement;
  bool _hasEau = false;
  bool _hasElec = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (ctx, ctrl) => Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Publier un bien',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type bien
                    const Text('Type de bien', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilterChipWidget(
                            label: '🏠 Logement',
                            isSelected: _typeBien == TypeBien.logement,
                            onTap: () => setState(() => _typeBien = TypeBien.logement),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilterChipWidget(
                            label: '🏪 Local commercial',
                            isSelected: _typeBien == TypeBien.localCommercial,
                            onTap: () => setState(() => _typeBien = TypeBien.localCommercial),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Type location
                    const Text('Durée de location', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilterChipWidget(
                            label: 'Long terme',
                            isSelected: _typeLocation == TypeLocation.longTerme,
                            onTap: () => setState(() => _typeLocation = TypeLocation.longTerme),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilterChipWidget(
                            label: 'Court terme',
                            isSelected: _typeLocation == TypeLocation.courtTerme,
                            onTap: () => setState(() => _typeLocation = TypeLocation.courtTerme),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titreCtrl,
                      decoration: const InputDecoration(labelText: 'Titre du bien *'),
                      validator: (v) => v == null || v.isEmpty ? 'Titre requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description *'),
                      validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prixCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _typeLocation == TypeLocation.courtTerme
                            ? 'Prix par nuit (FCFA) *'
                            : 'Loyer mensuel (FCFA) *',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Prix requis' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _villeCtrl,
                            decoration: const InputDecoration(labelText: 'Ville *'),
                            validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _secteurCtrl,
                            decoration: const InputDecoration(labelText: 'Secteur *'),
                            validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Équipements', style: TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Checkbox(
                          value: _hasEau,
                          onChanged: (v) => setState(() => _hasEau = v!),
                          activeColor: ImmoFasoTheme.primary,
                        ),
                        const Text('Eau'),
                        const SizedBox(width: 16),
                        Checkbox(
                          value: _hasElec,
                          onChanged: (v) => setState(() => _hasElec = v!),
                          activeColor: ImmoFasoTheme.primary,
                        ),
                        const Text('Électricité'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Photos placeholder
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ImmoFasoTheme.border,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 36, color: ImmoFasoTheme.textLight),
                              SizedBox(height: 8),
                              Text(
                                'Ajouter des photos',
                                style: TextStyle(color: ImmoFasoTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Publier mon bien',
                      isLoading: _isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isLoading = true);
                        await Future.delayed(const Duration(seconds: 1));
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bien publié avec succès ! En attente de validation.'),
                              backgroundColor: Color.fromARGB(255, 209, 97, 11),
                            ),
                          );
                        }
                      },
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
