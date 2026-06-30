import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/caracteristiques_bien.dart';

class PublierBienScreen extends StatefulWidget {
  final VoidCallback? onPublished;
  const PublierBienScreen({super.key, this.onPublished});

  @override
  State<PublierBienScreen> createState() => _PublierBienScreenState();
}

class _PublierBienScreenState extends State<PublierBienScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _titreCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _secteurCtrl  = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _prixCtrl     = TextEditingController();

  String _ville        = 'Ouagadougou';
  String _typeLocation = 'long_terme';
  String _typeBien     = 'villa';
  int    _chambres     = 1;
  int    _sallesDeBain = 1;
  bool   _clim         = false;
  bool   _wifi         = false;
  bool   _parking      = false;
  bool   _eau          = true;
  bool   _electricite  = true;
  bool   _courCommune  = false;
  bool   _salleEau     = false;

  final List<File>      _photos      = [];
  final List<Uint8List> _photosBytes = [];
  final List<Chambre> _chambresHotel = [];
  final _picker = ImagePicker();

  // ── Listes ──
  static const _villes = [
    'Ouagadougou', 'Bobo-Dioulasso', 'Koudougou', 'Banfora', 'Ouahigouya',
  ];

  static const _typesBien = [
  {'value': 'villa',            'label': 'Villa',            'icon': Icons.house},
  {'value': 'residence',        'label': 'Résidence',        'icon': Icons.apartment},
  {'value': 'auberge',          'label': 'Auberge',          'icon': Icons.hotel},
  {'value': 'hotel',            'label': 'Hôtel',            'icon': Icons.business},
  {'value': 'local_commercial', 'label': 'Local commercial', 'icon': Icons.store},
];

static const _typesLocation = [
  {'value': 'long_terme', 'label': 'Long terme', 'icon': Icons.calendar_month},
  {'value': 'sejour',     'label': 'Séjour',     'icon': Icons.night_shelter},
];

List<Map<String, dynamic>> get _typesBienFiltres {
  if (_typeLocation == 'long_terme') {
    return _typesBien.where((t) => t['value'] == 'villa' || t['value'] == 'local_commercial').toList() ;
  } else {
    return _typesBien.where((t) =>
      t['value'] == 'residence' || t['value'] == 'auberge' || t['value'] == 'hotel'
    ).toList();
  }
}
  @override
  void dispose() {
    _titreCtrl.dispose(); _descCtrl.dispose(); _secteurCtrl.dispose();
    _quartierCtrl.dispose(); _prixCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    if (_photosBytes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Maximum 5 photos'), backgroundColor: Colors.orange,
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: HerressoTheme.primary),
            title: const Text('Choisir depuis la galerie'),
            onTap: () async {
              Navigator.pop(ctx);
              final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (image == null) return;
              final bytes = await image.readAsBytes();
              setState(() {
                _photosBytes.add(bytes);
                if (!kIsWeb) _photos.add(File(image.path));
              });
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
              setState(() {
                _photosBytes.add(bytes);
                if (!kIsWeb) _photos.add(File(image.path));
              });
            },
          ),
        ]),
      ),
    );
  }

  void _retirerPhoto(int index) {
    setState(() {
      _photosBytes.removeAt(index);
      if (!kIsWeb && index < _photos.length) _photos.removeAt(index);
    });
  }
  void _ajouterChambre() {
  final nomCtrl   = TextEditingController();
  final prixCtrl  = TextEditingController();
  String type     = 'standard';
  int capacite    = 1;
  bool pdej       = false;
  bool dej        = false;
  bool din        = false;
  int dispo       = 1;

  final typesHotel = [
    {'value': 'standard', 'label': 'Standard'},
    {'value': 'vip',      'label': 'VIP'},
    {'value': 'suite',    'label': 'Suite'},
    {'value': 'Luxueuse',    'label': 'Suite luxueuse'},
  ];

  final typesAuberge = [
    {'value': 'dortoir', 'label': 'Dortoir'},
    {'value': 'individuelle',  'label': 'individuelle'},
    {'value': 'famille', 'label': 'Famille'},
  ];

  final types = _typeBien == 'hotel' ? typesHotel : typesAuberge;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _typeBien == 'hotel' ? 'Ajouter une chambre' : 'Ajouter un hébergement',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Type
              const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: types.map((t) {
                  final selected = type == t['value'];
                  return GestureDetector(
                    onTap: () => setModalState(() => type = t['value']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? HerressoTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? HerressoTheme.primary : Colors.grey.shade300),
                      ),
                      child: Text(t['label']!, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Nom
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom de la chambre *', prefixIcon: Icon(Icons.bed)),
              ),
              const SizedBox(height: 12),

              // Prix
              TextField(
                controller: prixCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix par nuit (FCFA) *',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: 'FCFA',
                ),
              ),
              const SizedBox(height: 12),

              // Capacité
              Row(children: [
                const Text('Capacité (personnes) : ', style: TextStyle(fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { if (capacite > 1) setModalState(() => capacite--); }),
                Text('$capacite', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline, color: HerressoTheme.primary), onPressed: () => setModalState(() => capacite++)),
              ]),

              // Nombre disponible
              Row(children: [
                const Text('Chambres disponibles : ', style: TextStyle(fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { if (dispo > 1) setModalState(() => dispo--); }),
                Text('$dispo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline, color: HerressoTheme.primary), onPressed: () => setModalState(() => dispo++)),
              ]),
              const SizedBox(height: 12),

              // Repas (hôtel seulement)
              if (_typeBien == 'hotel') ...[
                const Text('Repas inclus', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Petit déjeuner'),
                  value: pdej,
                  activeColor: HerressoTheme.primary,
                  onChanged: (v) => setModalState(() => pdej = v!),
                ),
                CheckboxListTile(
                  title: const Text('Déjeuner'),
                  value: dej,
                  activeColor: HerressoTheme.primary,
                  onChanged: (v) => setModalState(() => dej = v!),
                ),
                CheckboxListTile(
                  title: const Text('Dîner'),
                  value: din,
                  activeColor: HerressoTheme.primary,
                  onChanged: (v) => setModalState(() => din = v!),
                ),
              ],

              // Auberge 
              if (_typeBien == 'auberge') ...[
                const Text('Repas inclus', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Petit déjeuner'),
                  value: pdej,
                  activeColor: HerressoTheme.primary,
                  onChanged: (v) => setModalState(() => pdej = v!),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nomCtrl.text.isEmpty || prixCtrl.text.isEmpty) return;
                    setState(() {
                      _chambresHotel.add(Chambre(
                        bienId:          0,
                        type:            type,
                        nom:             nomCtrl.text.trim(),
                        prix:            double.tryParse(prixCtrl.text) ?? 0,
                        capacite:        capacite,
                        petitDejeuner:   pdej,
                        dejeuner:        dej,
                        diner:           din,
                        nombreDisponible: dispo,
                      ));
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HerressoTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Future<void> _publier() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photosBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ajoutez au moins une photo'), backgroundColor: Colors.red,
      ));
      return;
    }

    final provider = context.read<ProprietaireProvider>();
    final ok = await provider.publierBien(
      titre:              _titreCtrl.text.trim(),
      description:        _descCtrl.text.trim(),
      ville:              _ville,
      secteur:            _secteurCtrl.text.trim(),
      quartier:           _quartierCtrl.text.trim(),
      typeLocation:       _typeLocation,
      typeBien:           _typeBien,
      nombreChambres:     _chambres,
      nombreSallesDeBain: _sallesDeBain,
      prix:               double.tryParse(_prixCtrl.text.trim()) ?? 0,
      climatisation:      _clim,
      wifi:               _wifi,
      parking:            _parking,
      eau:                _eau,
      electricite:        _electricite,
      photos: kIsWeb ? null : (_photos.isEmpty ? null : _photos),
      photosBytes: _photosBytes.isEmpty ? null : _photosBytes,
    );

     if (ok && (_typeBien == 'hotel' || _typeBien == 'auberge')) {
        final bienId = provider.mesBiens.last.id;
        for (final chambre in _chambresHotel) {
          await ApiService.ajouterChambre(
            bienId:           bienId,
            type:             chambre.type,
            nom:              chambre.nom,
            prix:             chambre.prix,
            capacite:         chambre.capacite,
            petitDejeuner:    chambre.petitDejeuner,
            dejeuner:         chambre.dejeuner,
            diner:            chambre.diner,
            nombreDisponible: chambre.nombreDisponible,
          );
        }
      }

    if (!mounted) return;
    if (ok) {
      widget.onPublished?.call();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Bien publié avec succès !'), backgroundColor: Colors.green,
      ));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerressoTheme.background,
      appBar: AppBar(
        title: const Text('Publier un bien'),
        centerTitle: true,
        actions: [
          Consumer<ProprietaireProvider>(builder: (_, p, __) => TextButton(
            onPressed: p.isLoading ? null : _publier,
            child: const Text('Publier', style: TextStyle(fontWeight: FontWeight.bold, color: HerressoTheme.primary)),
          )),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── PHOTOS ──
              _sectionTitre('Photos du bien', subtitle: 'Minimum 1, maximum 5'),
              _zonePhotos(),
              const SizedBox(height: 24),

              // ── INFOS GÉNÉRALES ──
              _sectionTitre('Informations générales'),
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(labelText: 'Titre *',),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 24),

                          // ── TYPE DE LOCATION ──
            _sectionTitre('Type de location'),
            _dropdownTypeLocation(),
            const SizedBox(height: 24),

            // ── TYPE DE BIEN ──
            _sectionTitre('Type de bien'),
            _grilleSelection(
              items: _typesBienFiltres,
              initialValue: _typeBien,
              onSelect: (v) => setState(() => _typeBien = v),
            ),
            const SizedBox(height: 24),

              // ── LOCALISATION ──
              _sectionTitre('Localisation'),
              _dropdownVille(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _secteurCtrl,
                decoration: const InputDecoration(labelText: 'Secteur *', ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              
              const SizedBox(height: 12),
              TextFormField(
                controller: _quartierCtrl,
                decoration: const InputDecoration(labelText: 'Quartier *', ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 24),

              // ── PRIX ──
              _sectionTitre('Prix'),
              TextFormField(
                controller: _prixCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Prix (FCFA) *',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: 'FCFA',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 24),

            
            CaracteristiquesBien(
              typeBien: _typeBien,
              chambres: _chambres,
              onChambresChanged: (v) => setState(() => _chambres = v),
              sallesDeBain: _sallesDeBain,
              onSallesDeBainChanged: (v) => setState(() => _sallesDeBain = v),
              courCommune: _courCommune,
              onCourCommuneChanged: (v) => setState(() => _courCommune = v),
              salleEau: _salleEau,
              onSalleEauChanged: (v) => setState(() => _salleEau = v),
            ),
          
              _sectionTitre('Équipements & services'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _chip(label: 'Eau',          icone: Icons.water_drop_outlined, value: _eau,         onTap: () => setState(() => _eau = !_eau)),
                _chip(label: 'Électricité',  icone: Icons.bolt_outlined,       value: _electricite, onTap: () => setState(() => _electricite = !_electricite)),
                _chip(label: 'Climatisation',icone: Icons.ac_unit,             value: _clim,        onTap: () => setState(() => _clim = !_clim)),
                _chip(label: 'Wifi',         icone: Icons.wifi,                value: _wifi,        onTap: () => setState(() => _wifi = !_wifi)),
                _chip(label: 'Parking',      icone: Icons.local_parking,       value: _parking,     onTap: () => setState(() => _parking = !_parking)),
              ]),
               const SizedBox(height: 24),
              // CHAMBRES (hôtel / auberge)
              if (_typeBien == 'hotel' || _typeBien == 'auberge') ...[
                const SizedBox(height: 24),
                _sectionTitre(
                  _typeBien == 'hotel' ? 'Types de chambres' : 'Types d\'hébergement',
                  subtitle: 'Ajoutez chaque type avec son prix',
                ),
                ..._chambresHotel.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: HerressoTheme.border),
                    ),
                    child: Row(children: [
                      const Icon(Icons.bed_outlined, color: HerressoTheme.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${c.prix.toStringAsFixed(0)} FCFA/nuit · ${c.capacite} pers. · ${c.nombreDisponible} dispo',
                          style: const TextStyle(fontSize: 12, color: HerressoTheme.textSecondary),
                        ),
                        if (c.petitDejeuner || c.dejeuner || c.diner)
                          Text(
                            'Inclus : ${[if (c.petitDejeuner) 'Petit déj', if (c.dejeuner) 'Déjeuner', if (c.diner) 'Dîner'].join(', ')}',
                            style: const TextStyle(fontSize: 11, color: Colors.green),
                          ),
                      ])),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _chambresHotel.removeAt(i)),
                      ),
                    ]),
                  );
                }),
                GestureDetector(
                  onTap: _ajouterChambre,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: HerressoTheme.primary, style: BorderStyle.solid),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add, color: HerressoTheme.primary),
                      SizedBox(width: 8),
                      Text('Ajouter un type de chambre', style: TextStyle(color: HerressoTheme.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],

              if (_typeBien == 'hotel' || _typeBien == 'auberge') ...[
                _sectionTitre(_typeBien == 'hotel' ? 'Chambres' : 'Hébergements'),
                if (_chambresHotel.isEmpty)
                  const Text('Aucune chambre ajoutée.', style: TextStyle(color: Colors.black54)),
                if (_chambresHotel.isNotEmpty)
                  Column(
                    children: _chambresHotel.map((chambre) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HerressoTheme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(
                            '${chambre.nom} · ${chambre.type} · ${chambre.capacite} pers.',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text('${chambre.prix.toStringAsFixed(0)} FCFA'),
                        ],
                      ),
                    )).toList(),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _ajouterChambre,
                    icon: const Icon(Icons.add),
                    label: Text(_typeBien == 'hotel' ? 'Ajouter une chambre' : 'Ajouter un hébergement'),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              
              Consumer<ProprietaireProvider>(builder: (_, p, __) {
                if (p.erreur == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(p.erreur!, style: const TextStyle(color: Colors.red))),
                  ]),
                );
              }),

            
              Consumer<ProprietaireProvider>(builder: (_, p, __) => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: p.isLoading ? null : _publier,
                  icon: p.isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.publish),
                  label: Text(p.isLoading ? 'Publication en cours...' : 'Publier le bien'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HerressoTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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

  Widget _zonePhotos() {
    return Column(children: [
      if (_photosBytes.isNotEmpty) ...[
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photosBytes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) => Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(_photosBytes[i], width: 110, height: 110, fit: BoxFit.cover),
              ),
              Positioned(top: 4, right: 4, child: GestureDetector(
                onTap: () => _retirerPhoto(i),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              )),
              if (i == 0)
                Positioned(bottom: 4, left: 4, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: HerressoTheme.primary, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Principale', style: TextStyle(color: Colors.white, fontSize: 10)),
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
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_a_photo_outlined, color: HerressoTheme.primary, size: 28),
              const SizedBox(width: 8),
              Text('Ajouter une photo (${_photosBytes.length}/5)',
                  style: const TextStyle(color: HerressoTheme.primary, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
    ]);
  }

  Widget _grilleSelection({
    required List<Map<String, dynamic>> items,
    required String initialValue,
    required ValueChanged<String> onSelect,
    int colonnes = 3,
  }) {
    return GridView.count(
      crossAxisCount: colonnes,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.4,
      children: items.map((item) {
        final selected = initialValue == item['value'];
        return GestureDetector(
          onTap: () => onSelect(item['value'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? HerressoTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? HerressoTheme.primary : HerressoTheme.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(item['icon'] as IconData,
                  size: 22, color: selected ? Colors.white : HerressoTheme.primary),
              const SizedBox(height: 4),
              Text(item['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : HerressoTheme.textPrimary,
                  )),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _dropdownVille() => DropdownButtonFormField<String>(
    initialValue: _ville,
    decoration: const InputDecoration(labelText: 'Ville', prefixIcon: Icon(Icons.location_city_outlined)),
    items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
    onChanged: (v) => setState(() => _ville = v!),
  );
  Widget _dropdownTypeLocation() => DropdownButtonFormField<String>(
  initialValue: _typeLocation,
  decoration: const InputDecoration(
    labelText: 'Type de location',
    prefixIcon: Icon(Icons.calendar_month),
  ),
  items: _typesLocation.map((t) => DropdownMenuItem(
    value: t['value'] as String,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(t['icon'] as IconData, size: 18, color: HerressoTheme.primary),
        const SizedBox(width: 8),
        Text(t['label'] as String),
      ],
    ),
  )).toList(),
  onChanged: (v) {
    setState(() {
      _typeLocation = v!;
      _typeBien = _typesBienFiltres.first['value'] as String;
    });
  },
);

  

  

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