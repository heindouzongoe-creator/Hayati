import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/cnib_form_widget.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/phone_field.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

// ════════════════════════════════════════
// LOGIN SCREEN
// ════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onGoRegister;
  const LoginScreen({super.key, required this.onLoginSuccess, required this.onGoRegister});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _telephone = '';
  bool _showPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose(); _telCtrl.dispose(); _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (_emailCtrl.text.trim().isEmpty && _telephone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renseignez votre email ou votre numéro de téléphone'), backgroundColor: Colors.red));
      return;
    }
    final auth = context.read<AuthProvider>();
    final identifiant = _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : _telephone;
    final success = await auth.login(identifiant, _passwordCtrl.text);
    if (success && mounted) widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerressoTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(width: 80, height: 80, decoration: BoxDecoration(color: HerressoTheme.primary, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.home_work, color: Colors.white, size: 45)),
                const SizedBox(height: 16),
                const Text('Herresso', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: HerressoTheme.primary)),
                const Text('Trouvez votre logement au Burkina', style: TextStyle(color: HerressoTheme.textSecondary)),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) { if ((v == null || v.isEmpty) && _telephone.isEmpty) return 'Email ou téléphone requis'; return null; },
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OU', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600))),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ]),
                const SizedBox(height: 12),
                PhoneFieldWidget(controller: _telCtrl, onChanged: (n) => setState(() => _telephone = n), validator: (_) => null),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPassword = !_showPassword)),
                  ),
                  validator: (v) => v == null || v.length < 4 ? 'Minimum 4 caractères' : null,
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Mot de passe oublié ?'))),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(builder: (ctx, auth, _) {
                  if (auth.error != null) {
                    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                      child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text(auth.error!, style: const TextStyle(color: Colors.red)))]),
                    ));
                  }
                  return const SizedBox.shrink();
                }),
                Consumer<AuthProvider>(builder: (ctx, auth, _) => PrimaryButton(label: 'Se connecter', onPressed: _login, isLoading: auth.isLoading, icon: Icons.login)),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Pas encore de compte ? '),
                  TextButton(onPressed: widget.onGoRegister, child: const Text("S'inscrire", style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 16),
                OutlinedButton.icon(onPressed: widget.onLoginSuccess, icon: const Icon(Icons.visibility_outlined), label: const Text('Parcourir sans compte'), style: OutlinedButton.styleFrom(foregroundColor: HerressoTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// REGISTER SCREEN
// ════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onGoLogin;
  const RegisterScreen({super.key, required this.onSuccess, required this.onGoLogin});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _telephone = '';
  RoleUtilisateur _role = RoleUtilisateur.locataire;
  bool _showPassword = false;
  File? _selfiePhoto;
  Uint8List? _selfiePhotoBytes;
  CnibFormData? _cnibData;

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _emailCtrl.dispose();
    _telCtrl.dispose(); _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80, preferredCameraDevice: CameraDevice.front);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selfiePhoto = File(picked.path);
        _selfiePhotoBytes = bytes;
        
      });
    }
  }

  Future<void> _pickSelfieGallery() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (picked != null) {
    final bytes = await picked.readAsBytes();
    setState(() {
      _selfiePhoto = kIsWeb ? null : File(picked.path);
      _selfiePhotoBytes = bytes;
    });
  }
}
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Locataire : juste nom, prénom, téléphone/email
    if (_role == RoleUtilisateur.locataire) {
      if (_nomCtrl.text.trim().isEmpty || _prenomCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom et prénom obligatoires'), backgroundColor: Colors.red));
        return;
      }
      if (_emailCtrl.text.trim().isEmpty && _telephone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renseignez au moins un email ou un numéro de téléphone'), backgroundColor: Colors.red));
        return;
      }
    }

    // Propriétaire : selfie obligatoire, CNIB optionnelle
    if (_role == RoleUtilisateur.proprietaire) {
      
      if (_selfiePhoto == null && _selfiePhotoBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La photo de profil est obligatoire'), backgroundColor: Colors.red));
        return;
      }
    }

    final nom = (_role == RoleUtilisateur.proprietaire && (_cnibData?.nom.isNotEmpty ?? false))
        ? _cnibData!.nom : _nomCtrl.text.trim();
    final prenom = (_role == RoleUtilisateur.proprietaire && (_cnibData?.prenom.isNotEmpty ?? false))
        ? _cnibData!.prenom : _prenomCtrl.text.trim();

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      nom: nom,
      prenom: prenom,
      email: _emailCtrl.text.trim(),
      telephone: _telephone,
      motDePasse: _passwordCtrl.text,
      role: _role,
      cnibNumero: _cnibData?.numero ?? '',
      cnibPhoto: kIsWeb ? File('') : (_cnibData?.photoCnib ?? File('')),
      selfiePhoto: kIsWeb ? File('') : (_selfiePhoto ?? File('')),
      selfiePhotoBytes: _selfiePhotoBytes,
      cnibPhotoBytes: _cnibData?.photoCnibBytes,
    );
    if (success && mounted) widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final estProprietaire = _role == RoleUtilisateur.proprietaire;

    return Scaffold(
      backgroundColor: HerressoTheme.background,
      appBar: AppBar(title: const Text('Créer un compte'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGoLogin)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rejoignez Herresso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Créez votre compte gratuitement', style: TextStyle(color: HerressoTheme.textSecondary)),
              const SizedBox(height: 24),

              // ── Rôle ──
              const Text('Je suis :', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _roleCard(role: RoleUtilisateur.locataire, icon: Icons.person_search, label: 'Locataire', subtitle: 'Je cherche un logement')),
                const SizedBox(width: 12),
                Expanded(child: _roleCard(role: RoleUtilisateur.proprietaire, icon: Icons.home, label: 'Propriétaire', subtitle: 'Je loue mes biens')),
              ]),
              const SizedBox(height: 24),

              // ── Nom & Prénom (locataire seulement — propriétaire les a via CNIB) ──
              if (!estProprietaire) ...[
                Row(children: [
                  Expanded(child: TextFormField(controller: _nomCtrl, decoration: const InputDecoration(labelText: 'Nom *'), inputFormatters: [UpperCaseTextFormatter()], validator: (v) => v == null || v.isEmpty ? 'Requis' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _prenomCtrl, decoration: const InputDecoration(labelText: 'Prénom *'), validator: (v) => v == null || v.isEmpty ? 'Requis' : null)),
                ]),
                const SizedBox(height: 16),
              ],

              // ── Téléphone (principal pour locataire) ──
              PhoneFieldWidget(controller: _telCtrl, onChanged: (n) => setState(() => _telephone = n)),
              const SizedBox(height: 12),

              // ── Email (optionnel) ──
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: estProprietaire ? 'Email *' : 'Email (optionnel)', prefixIcon: const Icon(Icons.email_outlined))),
              const SizedBox(height: 16),

              // ── Mot de passe ──
              TextFormField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPassword = !_showPassword)),
                ),
                validator: (v) => v == null || v.length < 6 ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: 24),

              // ── PROPRIÉTAIRE : scan pièce + selfie ──
              if (estProprietaire) ...[
                // Info certification
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                  child: const Row(children: [
                    Icon(Icons.verified, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('En tant que propriétaire, votre pièce d\'identité est obligatoire. Votre profil sera certifié ✅ après vérification.', style: TextStyle(fontSize: 12, color: Colors.blue))),
                  ]),
                ),
                const SizedBox(height: 16),

                CnibFormWidget(onChanged: (data) => setState(() => _cnibData = data), verrouille: true),
                const SizedBox(height: 16),

                // Photo de profil
                const Text('Photo de profil *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Cette photo sera visible sur votre profil', style: TextStyle(color: HerressoTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                _photoPickerCard(photoBytes: _selfiePhotoBytes, icon: Icons.face, label: 'Prendre un selfie', onTap: _takeSelfie, onTapGallery: _pickSelfieGallery),
                const SizedBox(height: 16),
              ],

              // ── Info ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    estProprietaire
                        ? 'Votre pièce sera vérifiée par notre équipe. Compte certifié sous 24h.'
                        : 'Inscription rapide ! Vous pouvez compléter votre profil plus tard.',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  )),
                ]),
              ),
              const SizedBox(height: 32),

              Consumer<AuthProvider>(builder: (ctx, auth, _) {
                if (auth.error != null) {
                  return Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                    child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text(auth.error!, style: const TextStyle(color: Colors.red)))]),
                  ));
                }
                return const SizedBox.shrink();
              }),

              Consumer<AuthProvider>(builder: (ctx, auth, _) => PrimaryButton(label: "S'inscrire", onPressed: _register, isLoading: auth.isLoading, icon: Icons.person_add)),
              const SizedBox(height: 16),
              Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Déjà un compte ? '),
                TextButton(onPressed: widget.onGoLogin, child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.bold))),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPickerCard({required Uint8List? photoBytes, required IconData icon, required String label, required VoidCallback onTap, VoidCallback? onTapGallery}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 140,
        decoration: BoxDecoration(
          color: photoBytes != null ? Colors.transparent : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: photoBytes != null ? HerressoTheme.primary : Colors.grey.shade300, width: photoBytes != null ? 2 : 1),
        ),
        child: photoBytes != null
            ? Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.memory(photoBytes, width: double.infinity, height: 140, fit: BoxFit.cover)),
                Positioned(top: 8, right: 8, child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.edit, size: 16, color: Colors.black87)))),
                Positioned(bottom: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: HerressoTheme.primary, borderRadius: BorderRadius.circular(8)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check, size: 14, color: Colors.white), SizedBox(width: 4), Text('Photo ajoutée', style: TextStyle(color: Colors.white, fontSize: 12))]))),
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                if (onTapGallery != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(onTap: onTapGallery, child: const Text('ou choisir dans la galerie', style: TextStyle(color: HerressoTheme.primary, fontSize: 12, decoration: TextDecoration.underline))),
                ],
              ]),
      ),
    );
  }

  Widget _roleCard({required RoleUtilisateur role, required IconData icon, required String label, required String subtitle}) {
    final isSelected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? HerressoTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? HerressoTheme.primary : HerressoTheme.border, width: isSelected ? 2 : 1),
        ),
        child: Column(children: [
          Icon(icon, color: isSelected ? Colors.white : HerressoTheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : HerressoTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : HerressoTheme.textLight), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}