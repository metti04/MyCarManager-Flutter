import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../home/home_screen.dart';
import '../profilo/profilo_screen.dart';
import '../../theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  final String username;

  const MainScreen({super.key, required this.username});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Chiavi per i navigatori locali di ogni tab
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
  };

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final navigator = _navigatorKeys[_selectedIndex]?.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else if (_selectedIndex != 0) {
          // Se siamo su un'altra tab e non possiamo tornare indietro, torniamo alla Home
          setState(() => _selectedIndex = 0);
        } else {
          // Se siamo alla radice della Home, usciamo (o lasciamo gestire al sistema)
          // In Flutter 3.16+ PopScope canPop false blocca l'uscita, qui si potrebbe chiudere l'app
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(0, HomeScreen(username: widget.username)),
            _buildTabNavigator(1, ProfiloScreen(username: widget.username)),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColors.blu,
          indicatorColor: Colors.transparent,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == _selectedIndex) {
              // Se l'utente clicca di nuovo sulla tab attiva, torna alla radice della tab
              _navigatorKeys[index]?.currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          destinations: [
            _buildDestination(0, 'assets/images/ic_auto.svg', 'Garage'),
            _buildDestination(1, 'assets/images/ic_profilo.svg', 'Profilo'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => rootPage);
      },
    );
  }

  NavigationDestination _buildDestination(int index, String assetPath, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.azzurro : AppColors.bianco;
    return NavigationDestination(
      icon: SvgPicture.asset(
        assetPath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        width: 28,
        height: 28,
      ),
      label: label,
    );
  }
}
