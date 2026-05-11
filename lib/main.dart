// Commentaire inutile

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'theme.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';
import 'screens/biens_screens.dart';
import 'screens/profile_screen.dart';
import 'services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await NotificationService.init();
  await initializeDateFormatting('fr_FR', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ImmoFasoApp());
}

class ImmoFasoApp extends StatelessWidget {
  const ImmoFasoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BienProvider()),
      ],
      child: MaterialApp(
        title: 'ImmoFaso',
        debugShowCheckedModeBanner: false,
        theme: ImmoFasoTheme.theme,
        home: const AppNavigator(),
      ),
    );
  }
}

// ---- NAVIGATEUR PRINCIPAL ----
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  _AppPage _page = _AppPage.login;
  int _navIndex = 0;
  Bien? _selectedBien;

  void _goTo(_AppPage page) => setState(() => _page = page);

  void _onBienTap(Bien bien) {
    setState(() {
      _selectedBien = bien;
      _page = _AppPage.bienDetail;
    });
  }

  Widget _buildPage() {
    switch (_page) {
      case _AppPage.login:
        return LoginScreen(
          onLoginSuccess: () => _goTo(_AppPage.main),
          onGoRegister: () => _goTo(_AppPage.register),
        );
      case _AppPage.register:
        return RegisterScreen(
          onSuccess: () => _goTo(_AppPage.main),
          onGoLogin: () => _goTo(_AppPage.login),
        );
      case _AppPage.bienDetail:
        if (_selectedBien == null) {
          _goTo(_AppPage.main);
          return const SizedBox.shrink();
        }
        return BienDetailScreen(
          bien: _selectedBien!,
          onBack: () => _goTo(_AppPage.main),
        );
      case _AppPage.main:
        return _MainScaffold(
          navIndex: _navIndex,
          onNavChange: (i) => setState(() => _navIndex = i),
          onBienTap: _onBienTap,
          onLogout: () => _goTo(_AppPage.login),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildPage(),
    );
  }
}

enum _AppPage { login, register, main, bienDetail }

// ---- SCAFFOLD PRINCIPAL (Bottom Nav) ----
class _MainScaffold extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavChange;
  final Function(Bien) onBienTap;
  final VoidCallback onLogout;

  const _MainScaffold({
    required this.navIndex,
    required this.onNavChange,
    required this.onBienTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onBienTap: onBienTap,
        onVoirTout: () => onNavChange(1),
      ),
      BienListScreen(onBienTap: onBienTap),
      ProfileScreen(onLogout: onLogout, onBienTap: onBienTap),
    ];

    return Scaffold(
      body: IndexedStack(
        index: navIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navIndex,
        onTap: onNavChange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Rechercher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}