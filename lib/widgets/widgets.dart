// lib/widgets/widgets.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme.dart';

// Format prix FCFA
String formatPrix(double prix) {
  final formatter = NumberFormat('#,###', 'fr_FR');
  return '${formatter.format(prix)} FCFA';
}

// ---- CARTE DE BIEN ----
class BienCard extends StatelessWidget {
  final Bien bien;
  final VoidCallback onTap;
  final bool isHorizontal;

  const BienCard({
    super.key,
    required this.bien,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: isHorizontal ? _buildHorizontal() : _buildVertical(),
      ),
    );
  }

  Widget _buildVertical() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Stack(
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: bien.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: bien.photos.first,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (c, u, e) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.home, size: 60, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.home, size: 60, color: Colors.grey),
                    ),
            ),
            // Badge type
            Positioned(
              top: 10,
              left: 10,
              child: _buildBadgeType(),
            ),
            // Badge statut
            if (!bien.estDisponible)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Indisponible',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Infos
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bien.titre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      '${bien.localisation.secteur}, ${bien.localisation.ville}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatPrix(bien.prix)}${bien.typeLocation == TypeLocation.sejour ? '/nuit' : '/mois'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primary,
                    ),
                  ),
                  if (bien.note != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppTheme.secondary),
                        const SizedBox(width: 2),
                        Text(
                          bien.note!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${bien.nombreAvis})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Caractéristiques rapides
              Row(
                children: [
                  if (bien.nombreChambres != null) ...[
                    _iconInfo(Icons.bed_outlined, '${bien.nombreChambres} ch.'),
                    const SizedBox(width: 12),
                  ],
                  if (bien.hasEau)
                    _iconInfo(Icons.water_drop_outlined, 'Eau'),
                  const SizedBox(width: 12),
                  if (bien.hasElectricite)
                    _iconInfo(Icons.bolt_outlined, 'Elec.'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: bien.photos.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: bien.photos.first,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.home),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.home),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bien.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bien.localisation.ville,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrix(bien.prix),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
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

  Widget _buildBadgeType() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bien.typeLocation == TypeLocation.sejour
            ? AppTheme.secondary
            : AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        bien.typeLocation == TypeLocation.sejour ? 'Séjour' : 'Long terme',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

// ---- BARRE DE RECHERCHE ----
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher un logement...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: onFilterTap,
            ),
          ),
        ],
      ],
    );
  }
}

// ---- CARTE AVIS ----
class AvisCard extends StatelessWidget {
  final Avis avis;

  const AvisCard({super.key, required this.avis});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    avis.locataireNom.isNotEmpty
                        ? avis.locataireNom[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avis.locataireNom,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        DateFormat('d MMMM yyyy', 'fr_FR').format(avis.dateAvis),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: avis.note.toDouble(),
                  itemBuilder: (c, _) =>
                      const Icon(Icons.star, color: AppTheme.secondary),
                  itemCount: 5,
                  itemSize: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              avis.commentaire,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- SECTION TITRE ----
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
      ],
    );
  }
}

// ---- BOUTON PRIMAIRE ----
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primary,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

// ---- CHIP FILTRE ----
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ---- EMPTY STATE ----
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonLabel != null && onButton != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButton,
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
