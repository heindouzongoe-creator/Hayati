import 'package:flutter/material.dart';
import '../theme.dart';

class CaracteristiquesBien extends StatelessWidget {
  final String typeBien;

  
  final int chambres;
  final ValueChanged<int> onChambresChanged;

  
  final int sallesDeBain;
  final ValueChanged<int> onSallesDeBainChanged;

  
  final bool courCommune;
  final ValueChanged<bool> onCourCommuneChanged;

  
  final bool salleEau;
  final ValueChanged<bool> onSalleEauChanged;

  const CaracteristiquesBien({
    super.key,
    required this.typeBien,
    required this.chambres,
    required this.onChambresChanged,
    required this.sallesDeBain,
    required this.onSallesDeBainChanged,
    required this.courCommune,
    required this.onCourCommuneChanged,
    required this.salleEau,
    required this.onSalleEauChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (typeBien) {
      case 'villa':
      case 'residence':
        return _buildVillaResidence();
      case 'local_commercial':
        return _buildLocalCommercial();
      case 'hotel':
      case 'auberge':
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  
  Widget _buildVillaResidence() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Caractéristiques'),
        Row(children: [
          Expanded(child: _compteur(
            label: 'Chambres',
            icone: Icons.bed_outlined,
            value: chambres,
            onMoins: () { if (chambres > 0) onChambresChanged(chambres - 1); },
            onPlus: () => onChambresChanged(chambres + 1),
          )),
          const SizedBox(width: 12),
          Expanded(child: _compteur(
            label: 'Salle de bain',
            icone: Icons.bathroom_outlined,
            value: sallesDeBain,
            onMoins: () { if (sallesDeBain > 0) onSallesDeBainChanged(sallesDeBain - 1); },
            onPlus: () => onSallesDeBainChanged(sallesDeBain + 1),
          )),
        ]),
        const SizedBox(height: 24),

        
        if (typeBien == 'villa') ...[
          _sectionTitre('Type de cour'),
          Row(children: [
            Expanded(child: _toggleCard(
              label: 'Cour unique',
              icone: Icons.lock_outline,
              selected: !courCommune,
              onTap: () => onCourCommuneChanged(false),
            )),
            const SizedBox(width: 12),
            Expanded(child: _toggleCard(
              label: 'Cour commune',
              icone: Icons.people_outline,
              selected: courCommune,
              onTap: () => onCourCommuneChanged(true),
            )),
          ]),
          const SizedBox(height: 24),
        ],
      ],
    );
  }


  Widget _buildLocalCommercial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Caractéristiques'),
        _compteur(
          label: 'Nombre de pièces',
          icone: Icons.meeting_room_outlined,
          value: chambres,
          onMoins: () { if (chambres > 0) onChambresChanged(chambres - 1); },
          onPlus: () => onChambresChanged(chambres + 1),
        ),
        const SizedBox(height: 12),
        _chip(
          label: "Salle d'eau / Toilette",
          icone: Icons.wc_outlined,
          value: salleEau,
          onTap: () => onSalleEauChanged(!salleEau),
        ),
        const SizedBox(height: 24),
      ],
    );
  }


  Widget _sectionTitre(String titre, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      if (subtitle != null) ...[
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: HerressoTheme.textSecondary)),
      ],
    ]),
  );

  Widget _compteur({
    required String label,
    required IconData icone,
    required int value,
    required VoidCallback onMoins,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: HerressoTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Row(children: [
          Icon(icone, size: 16, color: HerressoTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: HerressoTheme.textSecondary)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: onMoins, child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.remove, size: 16),
          )),
          Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          GestureDetector(onTap: onPlus, child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: HerressoTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.add, size: 16, color: HerressoTheme.primary),
          )),
        ]),
      ]),
    );
  }

  Widget _toggleCard({
    required String label,
    required IconData icone,
    required bool selected,
    required VoidCallback onTap,
  }) {
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

  Widget _chip({
    required String label,
    required IconData icone,
    required bool value,
    required VoidCallback onTap,
  }) {
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