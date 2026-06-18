// lib/screens/proprietaire_screens.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/proprietaire_provider.dart';
import '../theme.dart';

// ═══════════════════════════════════════════════════════════
// 1. LISTE DE MES BIENS
// ═══════════════════════════════════════════════════════════

class MesBiensScreen extends StatefulWidget {
  const MesBiensScreen({super.key});

  @override
  State<MesBiensScreen> createState() => _MesBiensScreenState();
}

class _MesBiensScreenState extends State<MesBiensScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProprietaireProvider>().chargerMesBiens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerressoTheme.background,
      appBar: AppBar(
        title: const Text('Mes annonces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProprietaireProvider>().chargerMesBiens(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(context),
        backgroundColor: HerressoTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une annonce'),
      ),
      body: Consumer<ProprietaireProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: HerressoTheme.primary),
            );
          }

          if (provider.erreur != null) {
            return _EcranErreur(
              message: provider.erreur!,
              onRetry: () => provider.chargerMesBiens(),
            );
          }

          if (provider.mesBiens.isEmpty) {
            return _EcranVide(
              onAjouter: () => _ouvrirFormulaire(context),
            );
          }

          return Column(
            children: [
              // Résumé stats
              _StatsBandeau(provider: provider),
              // Liste
              Expanded(
                child: RefreshIndicator(
                  color: HerressoTheme.primary,
                  onRefresh: () => provider.chargerMesBiens(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: provider.mesBiens.length,
                    itemBuilder: (context, index) {
                      final bien = provider.mesBiens[index];
                      return _CarteMonBien(
                        bien: bien,
                        onTap: () => _ouvrirDetail(context, bien),
                        onModifier: () => _ouvrirFormulaire(context, bien: bien),
                        onSupprimer: () => _confirmerSuppression(context, bien),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _ouvrirFormulaire(BuildContext context, {Bien? bien}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormulaireiBienScreen(bienAModifier: bien),
      ),
    );
  }

  void _ouvrirDetail(BuildContext context, Bien bien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMonBienScreen(bien: bien),
      ),
    );
  }

  void _confirmerSuppression(BuildContext context, Bien bien) {
    showDialog(
      context: context,
      builder: (_) => DialogSuppressionBien(bien: bien),
    );
  }
}

// ─── Bandeau stats ───────────────────────────────────────

class _StatsBandeau extends StatelessWidget {
  final ProprietaireProvider provider;
  const _StatsBandeau({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HerressoTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _StatItem(
            label: 'Total',
            valeur: '${provider.totalBiens}',
            couleur: HerressoTheme.primary,
          ),
          _StatItem(
            label: 'Disponibles',
            valeur: '${provider.biensDisponibles}',
            couleur: Colors.green,
          ),
          _StatItem(
            label: 'Loués',
            valeur: '${provider.biensLoues}',
            couleur: HerressoTheme.warning,
          ),
          _StatItem(
            label: 'Réservés',
            valeur: '${provider.biensReserves}',
            couleur: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String valeur;
  final Color couleur;
  const _StatItem({required this.label, required this.valeur, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valeur,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: HerressoTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte d'un bien ─────────────────────────────────────

class _CarteMonBien extends StatelessWidget {
  final Bien bien;
  final VoidCallback onTap;
  final VoidCallback onModifier;
  final VoidCallback onSupprimer;

  const _CarteMonBien({
    required this.bien,
    required this.onTap,
    required this.onModifier,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo ou icône
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: bien.photos.isNotEmpty
                    ? Image.network(
                        bien.photos.first,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PhotoPlaceholder(bien: bien),
                      )
                    : _PhotoPlaceholder(bien: bien),
              ),
              const SizedBox(width: 12),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bien.titre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: HerressoTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _BadgeStatut(statut: bien.statut),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: HerressoTheme.textLight),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            bien.localisation.adresseComplete,
                            style: const TextStyle(
                              fontSize: 12,
                              color: HerressoTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_formatPrix(bien.prix)} FCFA / mois',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HerressoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Actions rapides
                    Row(
                      children: [
                        _BoutonAction(
                          label: 'Modifier',
                          icon: Icons.edit_outlined,
                          couleur: Colors.blue,
                          onTap: onModifier,
                        ),
                        const SizedBox(width: 8),
                        _BoutonAction(
                          label: 'Supprimer',
                          icon: Icons.delete_outline,
                          couleur: HerressoTheme.error,
                          onTap: onSupprimer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrix(double prix) {
    return prix.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final Bien bien;
  const _PhotoPlaceholder({required this.bien});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      color: HerressoTheme.primary.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            bien.typeBien == TypeBien.localCommercial
                ? Icons.store_outlined
                : Icons.home_outlined,
            color: HerressoTheme.primary,
            size: 32,
          ),
        ],
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  final StatutBien statut;
  const _BadgeStatut({required this.statut});

  @override
  Widget build(BuildContext context) {
    final (label, couleur) = switch (statut) {
      StatutBien.disponible => ('Disponible', Colors.green),
      StatutBien.louer => ('Loué', HerressoTheme.warning),
      StatutBien.reserve => ('Réservé', Colors.blue),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: couleur,
        ),
      ),
    );
  }
}

class _BoutonAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color couleur;
  final VoidCallback onTap;

  const _BoutonAction({
    required this.label,
    required this.icon,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: couleur),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: couleur,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Écran vide ──────────────────────────────────────────

class _EcranVide extends StatelessWidget {
  final VoidCallback onAjouter;
  const _EcranVide({required this.onAjouter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: HerressoTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 50,
                color: HerressoTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Vous n\'avez/pas encore d\'annonces',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: HerressoTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre première annonce pour commencer à recevoir des demandes.',
              style: TextStyle(color: HerressoTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAjouter,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une annonce'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Écran erreur ─────────────────────────────────────────

class _EcranErreur extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _EcranErreur({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 60, color: HerressoTheme.textLight),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: HerressoTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 2. DÉTAIL D'UN BIEN (vue proprio)
// ═══════════════════════════════════════════════════════════

class DetailMonBienScreen extends StatelessWidget {
  final Bien bien;
  const DetailMonBienScreen({super.key, required this.bien});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerressoTheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar avec photo
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: HerressoTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: bien.photos.isNotEmpty
                  ? Image.network(bien.photos.first, fit: BoxFit.cover)
                  : Container(
                      color: HerressoTheme.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.home, size: 80, color: HerressoTheme.primary),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormulaireiBienScreen(bienAModifier: bien),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DialogSuppressionBien(
                    bien: bien,
                    onSupprime: () => Navigator.popUntil(context, (r) => r.isFirst),
                  ),
                ),
              ),
            ],
          ),
          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + statut
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          bien.titre,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: HerressoTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _BadgeStatut(statut: bien.statut),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Localisation
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: HerressoTheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bien.localisation.adresseComplete,
                          style: const TextStyle(color: HerressoTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Prix
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: HerressoTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Loyer mensuel',
                          style: TextStyle(color: HerressoTheme.textSecondary),
                        ),
                        Text(
                          '${_formatPrix(bien.prix)} FCFA',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: HerressoTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Caractéristiques
                  _SectionTitre(titre: 'Caractéristiques'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (bien.nombreChambres != null)
                        _ChipInfo(
                          icon: Icons.bed_outlined,
                          label: '${bien.nombreChambres} chambre(s)',
                        ),
                      _ChipInfo(
                        icon: Icons.water_drop_outlined,
                        label: bien.hasEau ? 'Eau' : 'Sans eau',
                        actif: bien.hasEau,
                      ),
                      _ChipInfo(
                        icon: Icons.bolt_outlined,
                        label: bien.hasElectricite ? 'Électricité' : 'Sans électricité',
                        actif: bien.hasElectricite,
                      ),
                      ...bien.caracteristiques.map((c) => _ChipInfo(
                            icon: Icons.check_circle_outline,
                            label: '${c.nom}: ${c.valeur}',
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  if (bien.description.isNotEmpty) ...[
                    _SectionTitre(titre: 'Description'),
                    const SizedBox(height: 8),
                    Text(
                      bien.description,
                      style: const TextStyle(
                        color: HerressoTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Changer le statut
                  _SectionTitre(titre: 'Changer le statut'),
                  const SizedBox(height: 8),
                  _ChangerStatut(bien: bien),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrix(double prix) {
    return prix.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}

class _SectionTitre extends StatelessWidget {
  final String titre;
  const _SectionTitre({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Text(
      titre,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: HerressoTheme.textPrimary,
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool actif;
  const _ChipInfo({required this.icon, required this.label, this.actif = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: actif
            ? HerressoTheme.primary.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: actif
              ? HerressoTheme.primary.withValues(alpha: 0.3)
              : HerressoTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: actif ? HerressoTheme.primary : HerressoTheme.textLight),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: actif ? HerressoTheme.textPrimary : HerressoTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Changer statut ──────────────────────────────────────

class _ChangerStatut extends StatelessWidget {
  final Bien bien;
  const _ChangerStatut({required this.bien});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BoutonStatut(
          label: 'Disponible',
          couleur: Colors.green,
          actif: bien.statut == StatutBien.disponible,
          onTap: () => _changerStatut(context, StatutBien.disponible),
        ),
        const SizedBox(width: 8),
        _BoutonStatut(
          label: 'Loué',
          couleur: HerressoTheme.warning,
          actif: bien.statut == StatutBien.louer,
          onTap: () => _changerStatut(context, StatutBien.louer),
        ),
        const SizedBox(width: 8),
        _BoutonStatut(
          label: 'Réservé',
          couleur: Colors.blue,
          actif: bien.statut == StatutBien.reserve,
          onTap: () => _changerStatut(context, StatutBien.reserve),
        ),
      ],
    );
  }

  void _changerStatut(BuildContext context, StatutBien statut) async {
    final provider = context.read<ProprietaireProvider>();
    final ok = await provider.changerStatut(bien.id, statut);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Statut mis à jour ✓' : provider.erreur ?? 'Erreur'),
          backgroundColor: ok ? Colors.green : HerressoTheme.error,
        ),
      );
      if (ok) Navigator.pop(context);
    }
  }
}

class _BoutonStatut extends StatelessWidget {
  final String label;
  final Color couleur;
  final bool actif;
  final VoidCallback onTap;

  const _BoutonStatut({
    required this.label,
    required this.couleur,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: actif ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: actif ? couleur : couleur.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: couleur.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: actif ? Colors.white : couleur,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 3. FORMULAIRE AJOUT / MODIFICATION
// ═══════════════════════════════════════════════════════════

class FormulaireiBienScreen extends StatefulWidget {
  final Bien? bienAModifier;
  const FormulaireiBienScreen({super.key, this.bienAModifier});

  @override
  State<FormulaireiBienScreen> createState() => _FormulaireBienScreenState();
}

class _FormulaireBienScreenState extends State<FormulaireiBienScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  late final TextEditingController _titreCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _secteurCtrl;
  late final TextEditingController _quartierCtrl;
  late final TextEditingController _chambresCtrl;
  late final TextEditingController _sallesCtrl;

  // Valeurs
  String _ville = AppStrings.villes.first;
  String _typeBien = 'logement';
  String _typeLocation = 'long_terme';
  bool _eau = true;
  bool _electricite = true;
  bool _wifi = false;
  bool _parking = false;
  bool _climatisation = false;

  bool get _estModification => widget.bienAModifier != null;

  @override
  void initState() {
    super.initState();
    final b = widget.bienAModifier;
    _titreCtrl = TextEditingController(text: b?.titre ?? '');
    _descriptionCtrl = TextEditingController(text: b?.description ?? '');
    _prixCtrl = TextEditingController(text: b != null ? b.prix.toInt().toString() : '');
    _secteurCtrl = TextEditingController(text: b?.localisation.secteur ?? '');
    _quartierCtrl = TextEditingController(text: b?.localisation.adresse ?? '');
    _chambresCtrl = TextEditingController(text: b?.nombreChambres?.toString() ?? '1');
    _sallesCtrl = TextEditingController(text: '1');

    if (b != null) {
      _ville = AppStrings.villes.contains(b.localisation.ville)
          ? b.localisation.ville
          : AppStrings.villes.first;
      _typeBien = b.typeBien == TypeBien.localCommercial ? 'local_commercial' : 'logement';
      _typeLocation = b.typeLocation == TypeLocation.sejour ? 'sejour' : 'long_terme';
      _eau = b.hasEau;
      _electricite = b.hasElectricite;
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _prixCtrl.dispose();
    _secteurCtrl.dispose();
    _quartierCtrl.dispose();
    _chambresCtrl.dispose();
    _sallesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerressoTheme.background,
      appBar: AppBar(
        title: Text(_estModification ? 'Modifier l\'annonce' : 'Ajouter une annonce'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Type de bien ──
              _SectionTitre(titre: 'Type d\'annonce'),
              const SizedBox(height: 8),
              _ChoixSegment<String>(
                valeurs: const ['logement', 'local_commercial'],
                labels: const ['Logement', 'Local commercial'],
                valeurActuelle: _typeBien,
                onChange: (v) => setState(() => _typeBien = v),
              ),
              const SizedBox(height: 16),

              // ── Type de location ──
              _SectionTitre(titre: 'Type de location'),
              const SizedBox(height: 8),
              _ChoixSegment<String>(
                valeurs: const ['long_terme', 'sejour'],
                labels: const ['Long terme', 'Séjour (nuit/semaine)'],
                valeurActuelle: _typeLocation,
                onChange: (v) => setState(() => _typeLocation = v),
              ),
              const SizedBox(height: 16),

              // ── Titre ──
              _SectionTitre(titre: 'Titre de l\'annonce'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ex: Belle villa F4 à Ouaga 2000',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // ── Localisation ──
              _SectionTitre(titre: 'Localisation'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _ville,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_city_outlined),
                  hintText: 'Ville',
                ),
                items: AppStrings.villes
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => _ville = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _secteurCtrl,
                decoration: const InputDecoration(
                  hintText: 'Secteur (ex: Secteur 15)',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quartierCtrl,
                decoration: const InputDecoration(
                  hintText: 'Quartier / adresse précise',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // ── Prix ──
              _SectionTitre(titre: 'Prix (FCFA)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prixCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ex: 50000',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: 'FCFA',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (double.tryParse(v) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Chambres / Salles de bain ──
              if (_typeBien == 'logement') ...[
                _SectionTitre(titre: 'Détails'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _chambresCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Chambres',
                          prefixIcon: Icon(Icons.bed_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sallesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Salles de bain',
                          prefixIcon: Icon(Icons.bathtub_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // ── Équipements ──
              _SectionTitre(titre: 'Équipements'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    _ToggleEquipement(
                      label: 'Eau courante',
                      icon: Icons.water_drop_outlined,
                      valeur: _eau,
                      onChange: (v) => setState(() => _eau = v),
                    ),
                    const Divider(height: 1),
                    _ToggleEquipement(
                      label: 'Électricité',
                      icon: Icons.bolt_outlined,
                      valeur: _electricite,
                      onChange: (v) => setState(() => _electricite = v),
                    ),
                    const Divider(height: 1),
                    _ToggleEquipement(
                      label: 'Wifi',
                      icon: Icons.wifi_outlined,
                      valeur: _wifi,
                      onChange: (v) => setState(() => _wifi = v),
                    ),
                    const Divider(height: 1),
                    _ToggleEquipement(
                      label: 'Parking',
                      icon: Icons.local_parking_outlined,
                      valeur: _parking,
                      onChange: (v) => setState(() => _parking = v),
                    ),
                    const Divider(height: 1),
                    _ToggleEquipement(
                      label: 'Climatisation',
                      icon: Icons.ac_unit_outlined,
                      valeur: _climatisation,
                      onChange: (v) => setState(() => _climatisation = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Description ──
              _SectionTitre(titre: 'Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre annonce...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),

              // ── Bouton soumettre ──
              Consumer<ProprietaireProvider>(
                builder: (context, provider, _) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _soumettre,
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _estModification ? 'Enregistrer les modifications' : "Publier l'annonce",
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProprietaireProvider>();
    bool ok;

    if (_estModification) {
      ok = await provider.modifierBien(
        id: widget.bienAModifier!.id,
        titre: _titreCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        ville: _ville,
        secteur: _secteurCtrl.text.trim(),
        quartier: _quartierCtrl.text.trim(),
        prix: double.parse(_prixCtrl.text),
        typeLocation: _typeLocation,
        typeBien: _typeBien,
        nombreChambres: int.tryParse(_chambresCtrl.text) ?? 1,
        nombreSallesDeBain: int.tryParse(_sallesCtrl.text) ?? 1,
        eau: _eau,
        electricite: _electricite,
        wifi: _wifi,
        parking: _parking,
        climatisation: _climatisation,
      );
    } else {
      ok = await provider.publierBien(
        titre: _titreCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        ville: _ville,
        secteur: _secteurCtrl.text.trim(),
        quartier: _quartierCtrl.text.trim(),
        prix: double.parse(_prixCtrl.text),
        typeLocation: _typeLocation,
        typeBien: _typeBien,
        nombreChambres: int.tryParse(_chambresCtrl.text) ?? 1,
        nombreSallesDeBain: int.tryParse(_sallesCtrl.text) ?? 1,
        eau: _eau,
        electricite: _electricite,
        wifi: _wifi,
        parking: _parking,
        climatisation: _climatisation,
      );
    }

    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _estModification ? 'Annonce modifiée avec succès ✓' : 'Annonce publiée avec succès ✓',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.erreur ?? 'Une erreur est survenue'),
            backgroundColor: HerressoTheme.error,
          ),
        );
      }
    }
  }
}

// ─── Segment choice ──────────────────────────────────────

class _ChoixSegment<T> extends StatelessWidget {
  final List<T> valeurs;
  final List<String> labels;
  final T valeurActuelle;
  final ValueChanged<T> onChange;

  const _ChoixSegment({
    required this.valeurs,
    required this.labels,
    required this.valeurActuelle,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(valeurs.length, (i) {
        final actif = valeurs[i] == valeurActuelle;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChange(valeurs[i]),
            child: Container(
              margin: EdgeInsets.only(right: i < valeurs.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: actif ? HerressoTheme.primary : HerressoTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: actif ? HerressoTheme.primary : HerressoTheme.border,
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: actif ? Colors.white : HerressoTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Toggle équipement ───────────────────────────────────

class _ToggleEquipement extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool valeur;
  final ValueChanged<bool> onChange;

  const _ToggleEquipement({
    required this.label,
    required this.icon,
    required this.valeur,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: valeur,
      onChanged: onChange,
      activeThumbColor: HerressoTheme.primary,
      title: Row(
        children: [
          Icon(icon, size: 18, color: HerressoTheme.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
      dense: true,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 4. DIALOGUE CONFIRMATION SUPPRESSION
// ═══════════════════════════════════════════════════════════

class DialogSuppressionBien extends StatelessWidget {
  final Bien bien;
  final VoidCallback? onSupprime;

  const DialogSuppressionBien({
    super.key,
    required this.bien,
    this.onSupprime,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: HerressoTheme.error, size: 28),
          SizedBox(width: 8),
          Text('Supprimer cette annonce ?'),
        ],
      ),
      content: Text(
        'Vous êtes sur le point de supprimer "${bien.titre}". Cette action est irréversible.',
        style: const TextStyle(color: HerressoTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Annuler',
            style: TextStyle(color: HerressoTheme.textSecondary),
          ),
        ),
        Consumer<ProprietaireProvider>(
          builder: (context, provider, _) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HerressoTheme.error,
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
                    final ok = await provider.supprimerBien(bien.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (ok) {
                        onSupprime?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Annonce supprimée ✓'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.erreur ?? 'Erreur lors de la suppression'),
                            backgroundColor: HerressoTheme.error,
                          ),
                        );
                      }
                    }
                  },
            child: provider.isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Supprimer'),
          ),
        ),
      ],
    );
  }
}