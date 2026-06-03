// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  final Function(Bien) onBienTap;
  final VoidCallback onVoirTout;

  const HomeScreen({
    super.key,
    required this.onBienTap,
    required this.onVoirTout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedVille = 'Tous';
  TypeLocation? _typeLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BienProvider>().chargerBiens();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bienProvider = context.watch<BienProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar avec dégradé
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryDark,
                      AppTheme.primary,
                      AppTheme.primaryLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.isLoggedIn
                                      ? 'Bonjour, ${auth.currentUser!.prenom} 👋'
                                      : 'Bienvenue 👋',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  'Trouvez votre logement',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () {},
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) {
                              context.read<BienProvider>().rechercher(v);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Ville, quartier, type de bien...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppTheme.primary,
                              ),
                              border: InputBorder.none,
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        context.read<BienProvider>().rechercher('');
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: const Text('Herresso'),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtres ville
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'Tous',
                        ...AppStrings.villes,
                      ].map((ville) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChipWidget(
                            label: ville,
                            isSelected: _selectedVille == ville,
                            onTap: () {
                              setState(() => _selectedVille = ville);
                              context.read<BienProvider>().filtrerParVille(ville);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filtres type location
                  Row(
                    children: [
                      Expanded(
                        child: _typeLocationBtn(null, 'Tous'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _typeLocationBtn(TypeLocation.longTerme, 'Long terme'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _typeLocationBtn(TypeLocation.sejour, 'Sejour'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Statistiques
                  _buildStats(bienProvider),
                  const SizedBox(height: 24),

                  // Offres récentes
                  SectionTitle(
                    title: 'Offres récentes',
                    actionLabel: 'Voir tout',
                    onAction: widget.onVoirTout,
                  ),
                  const SizedBox(height: 12),

                  if (bienProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  else if (bienProvider.biens.isEmpty)
                    const EmptyState(
                      icon: Icons.home_outlined,
                      title: 'Aucun bien trouvé',
                      subtitle: 'Essayez avec d\'autres critères de recherche',
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: bienProvider.biens.length > 6
                          ? 6
                          : bienProvider.biens.length,
                      itemBuilder: (ctx, i) {
                        final bien = bienProvider.biens[i];
                        return BienCard(
                          bien: bien,
                          onTap: () => widget.onBienTap(bien),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Banner CTA
                  _buildCtaBanner(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeLocationBtn(TypeLocation? type, String label) {
    final isSelected = _typeLocation == type;
    return GestureDetector(
      onTap: () {
        setState(() => _typeLocation = type);
        context.read<BienProvider>().filtrerParTypeLocation(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BienProvider provider) {
    final disponibles = provider.tousLesBiens
        .where((b) => b.statut == StatutBien.disponible)
        .length;
    final longTerme = provider.tousLesBiens
        .where((b) => b.typeLocation == TypeLocation.longTerme)
        .length;
    final sejour = provider.tousLesBiens
        .where((b) => b.typeLocation == TypeLocation.sejour)
        .length;

    return Row(
      children: [
        _statCard('$disponibles', 'Disponibles', Icons.home_outlined, AppTheme.success),
        const SizedBox(width: 12),
        _statCard('$longTerme', 'Long terme', Icons.calendar_month_outlined, AppTheme.primary),
        const SizedBox(width: 12),
        _statCard('$sejour', 'Sejour', Icons.bed_outlined, AppTheme.secondary),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha:0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vous avez un bien à louer ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Publiez votre annonce gratuitement sur Herresso',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 13),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Publier maintenant'),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.add_home_work_outlined,
            color: Colors.white30,
            size: 64,
          ),
        ],
      ),
    );
  }
}
