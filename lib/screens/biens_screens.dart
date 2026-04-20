// lib/screens/biens_screens.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

// ---- LISTE DES BIENS ----
class BienListScreen extends StatefulWidget {
  final Function(Bien) onBienTap;

  const BienListScreen({super.key, required this.onBienTap});

  @override
  State<BienListScreen> createState() => _BienListScreenState();
}

class _BienListScreenState extends State<BienListScreen> {
  final _searchCtrl = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BienProvider>().chargerBiens();
    });
  }

  void _showFiltres() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FiltresSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BienProvider>();

    return Scaffold(
      backgroundColor: ImmoFasoTheme.background,
      appBar: AppBar(
        title: const Text('Tous les biens'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              controller: _searchCtrl,
              onChanged: (v) => context.read<BienProvider>().rechercher(v),
              onFilterTap: _showFiltres,
            ),
          ),
          // Résultats count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${provider.biens.length} bien(s) trouvé(s)',
                  style: const TextStyle(
                    color: ImmoFasoTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: ImmoFasoTheme.primary),
                  )
                : provider.biens.isEmpty
                    ? EmptyState(
                        icon: Icons.home_outlined,
                        title: 'Aucun bien trouvé',
                        subtitle: 'Essayez de modifier vos filtres',
                      )
                    : _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: provider.biens.length,
                            itemBuilder: (ctx, i) => BienCard(
                              bien: provider.biens[i],
                              onTap: () => widget.onBienTap(provider.biens[i]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.biens.length,
                            itemBuilder: (ctx, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BienCard(
                                bien: provider.biens[i],
                                onTap: () => widget.onBienTap(provider.biens[i]),
                                isHorizontal: true,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FiltresSheet extends StatefulWidget {
  @override
  State<_FiltresSheet> createState() => _FiltresSheetState();
}

class _FiltresSheetState extends State<_FiltresSheet> {
  String _ville = 'Tous';
  TypeLocation? _typeLocation;
  double _prixMax = 500000;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, ctrl) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 20),
            const Text(
              'Filtrer les résultats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ville',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Tous', ...AppStrings.villes].map((v) {
                return FilterChipWidget(
                  label: v,
                  isSelected: _ville == v,
                  onTap: () => setState(() => _ville = v),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Type de location',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilterChipWidget(
                  label: 'Tous',
                  isSelected: _typeLocation == null,
                  onTap: () => setState(() => _typeLocation = null),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Long terme',
                  isSelected: _typeLocation == TypeLocation.longTerme,
                  onTap: () =>
                      setState(() => _typeLocation = TypeLocation.longTerme),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Court terme',
                  isSelected: _typeLocation == TypeLocation.courtTerme,
                  onTap: () =>
                      setState(() => _typeLocation = TypeLocation.courtTerme),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prix maximum',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  formatPrix(_prixMax),
                  style: const TextStyle(
                    color: ImmoFasoTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _prixMax,
              min: 10000,
              max: 500000,
              divisions: 49,
              activeColor: ImmoFasoTheme.primary,
              onChanged: (v) => setState(() => _prixMax = v),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _ville = 'Tous';
                        _typeLocation = null;
                        _prixMax = 500000;
                      });
                      final p = context.read<BienProvider>();
                      p.filtrerParVille('Tous');
                      p.filtrerParTypeLocation(null);
                      p.filtrerParPrixMax(null);
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final p = context.read<BienProvider>();
                      p.filtrerParVille(_ville);
                      p.filtrerParTypeLocation(_typeLocation);
                      p.filtrerParPrixMax(_prixMax < 500000 ? _prixMax : null);
                      Navigator.pop(context);
                    },
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- DETAIL BIEN ----
class BienDetailScreen extends StatefulWidget {
  final Bien bien;
  final VoidCallback onBack;

  const BienDetailScreen({super.key, required this.bien, required this.onBack});

  @override
  State<BienDetailScreen> createState() => _BienDetailScreenState();
}

class _BienDetailScreenState extends State<BienDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _currentImage = 0;
  bool _isFavoris = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _appelerProprietaire() async {
    final uri = Uri.parse('tel:${widget.bien.proprietaireTelephone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _demanderVisite() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demander une visite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez une date pour votre visite :'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Choisir une date'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (date != null && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Visite demandée pour le ${DateFormat('d MMMM yyyy', 'fr_FR').format(date)}',
                      ),
                      backgroundColor: ImmoFasoTheme.success,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _faireReservation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReservationSheet(bien: widget.bien),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bien = widget.bien;
    final avis = DemoData.getAvis(bien.id);

    return Scaffold(
      backgroundColor: ImmoFasoTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Photos carousel
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: ImmoFasoTheme.primary,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: widget.onBack,
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isFavoris ? Icons.favorite : Icons.favorite_border,
                        color: _isFavoris ? Colors.red : Colors.white,
                      ),
                    ),
                    onPressed: () => setState(() => _isFavoris = !_isFavoris),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.share, color: Colors.white),
                    ),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: bien.photos.isNotEmpty
                      ? Stack(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 300,
                                viewportFraction: 1.0,
                                onPageChanged: (i, _) =>
                                    setState(() => _currentImage = i),
                              ),
                              items: bien.photos.map((url) {
                                return CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorWidget: (c, u, e) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.home, size: 80),
                                  ),
                                );
                              }).toList(),
                            ),
                            // Indicateurs
                            if (bien.photos.length > 1)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: bien.photos.asMap().entries.map((e) {
                                    return Container(
                                      width: e.key == _currentImage ? 20 : 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        color: e.key == _currentImage
                                            ? Colors.white
                                            : Colors.white54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            // Badge photos
                            Positioned(
                              top: 80,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_currentImage + 1}/${bien.photos.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.home, size: 80, color: Colors.grey),
                          ),
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Infos principales
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  bien.titre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: bien.estDisponible
                                      ? ImmoFasoTheme.success.withValues(alpha:0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  bien.estDisponible ? 'Disponible' : 'Indisponible',
                                  style: TextStyle(
                                    color: bien.estDisponible
                                        ? ImmoFasoTheme.success
                                        : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: ImmoFasoTheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  bien.localisation.adresseComplete,
                                  style: const TextStyle(
                                    color: ImmoFasoTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatPrix(bien.prix),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: ImmoFasoTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    bien.typeLocation == TypeLocation.courtTerme
                                        ? 'par nuit'
                                        : 'par mois',
                                    style: const TextStyle(
                                      color: ImmoFasoTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (bien.note != null)
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: bien.note!,
                                      itemBuilder: (c, _) => const Icon(
                                        Icons.star,
                                        color: ImmoFasoTheme.secondary,
                                      ),
                                      itemCount: 5,
                                      itemSize: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${bien.note!.toStringAsFixed(1)} (${bien.nombreAvis} avis)',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tabs
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabCtrl,
                        labelColor: ImmoFasoTheme.primary,
                        unselectedLabelColor: ImmoFasoTheme.textSecondary,
                        indicatorColor: ImmoFasoTheme.primary,
                        tabs: const [
                          Tab(text: 'Détails'),
                          Tab(text: 'Caractéristiques'),
                          Tab(text: 'Avis'),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          // Tab Détails
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bien.description,
                                  style: const TextStyle(
                                    color: ImmoFasoTheme.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Propriétaire / Bailleur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: ImmoFasoTheme.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: ImmoFasoTheme.primaryLight,
                                        child: Text(
                                          bien.proprietaireNom.isNotEmpty
                                              ? bien.proprietaireNom[0]
                                              : 'P',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bien.proprietaireNom,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              bien.proprietaireTelephone,
                                              style: const TextStyle(
                                                color: ImmoFasoTheme.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _appelerProprietaire,
                                        icon: const Icon(
                                          Icons.call,
                                          color: ImmoFasoTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tab Caractéristiques
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Équipements principaux
                                Row(
                                  children: [
                                    _equipCard(
                                      Icons.water_drop_outlined,
                                      'Eau',
                                      bien.hasEau,
                                    ),
                                    const SizedBox(width: 12),
                                    _equipCard(
                                      Icons.bolt_outlined,
                                      'Électricité',
                                      bien.hasElectricite,
                                    ),
                                    if (bien.nombreChambres != null) ...[
                                      const SizedBox(width: 12),
                                      _equipCard(
                                        Icons.bed_outlined,
                                        '${bien.nombreChambres} Chambre(s)',
                                        true,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Autres caractéristiques',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...bien.caracteristiques.map(
                                  (c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: ImmoFasoTheme.success,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${c.nom} : ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(c.valeur),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tab Avis
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (bien.note != null) ...[
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          bien.note!.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: ImmoFasoTheme.primary,
                                          ),
                                        ),
                                        RatingBarIndicator(
                                          rating: bien.note!,
                                          itemBuilder: (c, _) => const Icon(
                                            Icons.star,
                                            color: ImmoFasoTheme.secondary,
                                          ),
                                          itemCount: 5,
                                          itemSize: 28,
                                        ),
                                        Text(
                                          '${bien.nombreAvis} avis',
                                          style: const TextStyle(
                                            color: ImmoFasoTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                ...avis.map(
                                  (a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: AvisCard(avis: a),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Boutons d'action en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: bien.typeLocation == TypeLocation.courtTerme
                  ? PrimaryButton(
                      label: 'Réserver maintenant',
                      onPressed: bien.estDisponible ? _faireReservation : null,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _demanderVisite,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Visiter'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _appelerProprietaire,
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text('Appeler'),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipCard(IconData icon, String label, bool dispo) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dispo
              ? ImmoFasoTheme.success.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: dispo ? ImmoFasoTheme.success : Colors.red,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dispo ? ImmoFasoTheme.success : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---- SHEET RÉSERVATION ----
class _ReservationSheet extends StatefulWidget {
  final Bien bien;

  const _ReservationSheet({required this.bien});

  @override
  State<_ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<_ReservationSheet> {
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _modePaiement = 'Orange Money';
  bool _isLoading = false;

  int get nombreJours =>
      _dateDebut != null && _dateFin != null
          ? _dateFin!.difference(_dateDebut!).inDays
          : 0;
  double get montantTotal => nombreJours * widget.bien.prix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 20),
          const Text(
            'Réserver ce bien',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _datePicker(
                  label: 'Arrivée',
                  date: _dateDebut,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _dateDebut = d);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _datePicker(
                  label: 'Départ',
                  date: _dateFin,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _dateDebut?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: _dateDebut?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _dateFin = d);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mode paiement
          const Text(
            'Mode de paiement',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Orange Money', 'Moov Money', 'Coris Money'].map((m) {
              return FilterChipWidget(
                label: m,
                isSelected: _modePaiement == m,
                onTap: () => setState(() => _modePaiement = m),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Récap prix
          if (nombreJours > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ImmoFasoTheme.primary.withValues(alpha:1.0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ImmoFasoTheme.primary.withValues(alpha:0.2),
                ),
              ),
              child: Column(
                children: [
                  _recapLigne('Prix par nuit', formatPrix(widget.bien.prix)),
                  _recapLigne('Nombre de nuits', '$nombreJours'),
                  const Divider(),
                  _recapLigne('Total', formatPrix(montantTotal), isBold: true),
                ],
              ),
            ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirmer la réservation',
            isLoading: _isLoading,
            onPressed: _dateDebut == null || _dateFin == null
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Réservation confirmée avec succès !'),
                          backgroundColor: ImmoFasoTheme.success,
                        ),
                      );
                    }
                  },
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: ImmoFasoTheme.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: ImmoFasoTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('d MMM yyyy', 'fr_FR').format(date)
                  : 'Choisir',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: date != null
                    ? ImmoFasoTheme.textPrimary
                    : ImmoFasoTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recapLigne(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? ImmoFasoTheme.primary : null,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
