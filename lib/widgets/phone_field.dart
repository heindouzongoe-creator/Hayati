import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class PaysAfriqueOuest {
  final String nom;
  final String code;
  final String drapeau;

  const PaysAfriqueOuest({
    required this.nom,
    required this.code,
    required this.drapeau,
  });

  String get affichage => '$drapeau $code';
}

const List<PaysAfriqueOuest> paysAfriqueOuest = [
  PaysAfriqueOuest(nom: 'Bénin',          code: '+229', drapeau: '🇧🇯'),
  PaysAfriqueOuest(nom: 'Burkina Faso',   code: '+226', drapeau: '🇧🇫'),
  PaysAfriqueOuest(nom: 'Cap-Vert',       code: '+238', drapeau: '🇨🇻'),
  PaysAfriqueOuest(nom: "Côte d'Ivoire",  code: '+225', drapeau: '🇨🇮'),
  PaysAfriqueOuest(nom: 'Gambie',         code: '+220', drapeau: '🇬🇲'),
  PaysAfriqueOuest(nom: 'Ghana',          code: '+233', drapeau: '🇬🇭'),
  PaysAfriqueOuest(nom: 'Guinée',         code: '+224', drapeau: '🇬🇳'),
  PaysAfriqueOuest(nom: 'Guinée-Bissau',  code: '+245', drapeau: '🇬🇼'),
  PaysAfriqueOuest(nom: 'Libéria',        code: '+231', drapeau: '🇱🇷'),
  PaysAfriqueOuest(nom: 'Mali',           code: '+223', drapeau: '🇲🇱'),
  PaysAfriqueOuest(nom: 'Mauritanie',     code: '+222', drapeau: '🇲🇷'),
  PaysAfriqueOuest(nom: 'Niger',          code: '+227', drapeau: '🇳🇪'),
  PaysAfriqueOuest(nom: 'Nigeria',        code: '+234', drapeau: '🇳🇬'),
  PaysAfriqueOuest(nom: 'Sénégal',        code: '+221', drapeau: '🇸🇳'),
  PaysAfriqueOuest(nom: 'Sierra Leone',   code: '+232', drapeau: '🇸🇱'),
  PaysAfriqueOuest(nom: 'Togo',           code: '+228', drapeau: '🇹🇬'),
];

class PhoneFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged; // retourne le numéro complet avec indicatif

  const PhoneFieldWidget({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<PhoneFieldWidget> createState() => _PhoneFieldWidgetState();
}

class _PhoneFieldWidgetState extends State<PhoneFieldWidget> {
  PaysAfriqueOuest _paysSelectionne = paysAfriqueOuest[1]; // Burkina Faso par défaut

  void _ouvrirSelecteurPays() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SelecteurPaysModal(
        paysSelectionne: _paysSelectionne,
        onSelection: (pays) {
          setState(() => _paysSelectionne = pays);
          Navigator.pop(ctx);
          widget.onChanged?.call('${pays.code}${widget.controller.text}');
        },
      ),
    );
  }

  String get numeroComplet => '${_paysSelectionne.code}${widget.controller.text}';

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (val) => widget.onChanged?.call('${_paysSelectionne.code}$val'),
      decoration: InputDecoration(
        labelText: 'Numéro de téléphone',
        hintText: '70 00 00 00',
        prefixIcon: GestureDetector(
          onTap: _ouvrirSelecteurPays,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _paysSelectionne.drapeau,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  _paysSelectionne.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
      validator: widget.validator ??
          (v) {
            if (v == null || v.isEmpty) return 'Numéro requis';
            if (v.length < 6) return 'Numéro trop court';
            return null;
          },
    );
  }
}

// ── Modal de sélection du pays ──
class _SelecteurPaysModal extends StatefulWidget {
  final PaysAfriqueOuest paysSelectionne;
  final ValueChanged<PaysAfriqueOuest> onSelection;

  const _SelecteurPaysModal({
    required this.paysSelectionne,
    required this.onSelection,
  });

  @override
  State<_SelecteurPaysModal> createState() => _SelecteurPaysModalState();
}

class _SelecteurPaysModalState extends State<_SelecteurPaysModal> {
  String _recherche = '';

  List<PaysAfriqueOuest> get _paysFiltres => paysAfriqueOuest
      .where((p) => p.nom.toLowerCase().contains(_recherche.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          // Barre de titre
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choisir le pays',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Recherche
                TextField(
                  onChanged: (v) => setState(() => _recherche = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un pays...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          // Liste des pays
          Expanded(
            child: ListView.builder(
              itemCount: _paysFiltres.length,
              itemBuilder: (ctx, i) {
                final pays = _paysFiltres[i];
                final isSelected = pays.code == widget.paysSelectionne.code;
                return ListTile(
                  onTap: () => widget.onSelection(pays),
                  leading: Text(pays.drapeau, style: const TextStyle(fontSize: 28)),
                  title: Text(
                    pays.nom,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? HerressoTheme.primary : Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pays.code,
                        style: TextStyle(
                          color: isSelected ? HerressoTheme.primary : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle, color: HerressoTheme.primary, size: 20),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}