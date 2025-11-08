// Import Flutter's Material Design components
import 'package:flutter/material.dart';
// Import all the different screens
import 'card_list_screen.dart';
import 'favorites_screen.dart';
import 'battle_screen.dart';
import 'settings_screen.dart';

// HomeScreen is the main navigation hub of the app
// It contains the bottom navigation bar and manages which screen is displayed
class HomeScreen extends StatefulWidget {
  // Callback function to toggle between light and dark theme
  final VoidCallback onThemeToggle;
  
  // Current theme mode (light or dark)
  final ThemeMode themeMode;
  
  // Constructor requires theme toggle function and current theme mode
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tracks which tab is currently selected (0=Cards, 1=Battle, 2=Favorites, 3=Settings)
  int _selectedIndex = 0;
  
  // GlobalKey allows us to access the FavoritesScreen's state from here
  // We use this to refresh favorites when user switches to that tab
  final GlobalKey<State<FavoritesScreen>> _favoritesKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    // List of all the screens corresponding to each tab
    final List<Widget> screens = [
      // Tab 0: Card List Screen (main browse screen)
      CardListScreen(
        onThemeToggle: widget.onThemeToggle,
        themeMode: widget.themeMode,
      ),
      // Tab 1: Battle Screen (compare two cards)
      BattleScreen(themeMode: widget.themeMode),
      // Tab 2: Favorites Screen (saved cards)
      FavoritesScreen(key: _favoritesKey, themeMode: widget.themeMode),
      // Tab 3: Settings Screen (app preferences)
      SettingsScreen(
        themeMode: widget.themeMode,
        onThemeToggle: widget.onThemeToggle,
      ),
    ];
    
    return Scaffold(
      // IndexedStack keeps all screens in memory but only shows the selected one
      // This preserves the state of each screen when switching tabs
      body: IndexedStack(
        index: _selectedIndex, // Which screen to show
        children: screens, // All the screens
      ),
      // Bottom navigation bar with 4 tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlight the current tab
        // Handle tab selection
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Switch to the selected tab
            
            // Special case: When user navigates to Favorites tab (index 2)
            // Refresh the favorites list to show any newly added favorites
            if (index == 2 && _favoritesKey.currentState != null) {
              // Wait a tiny bit for the tab to switch, then reload
              Future.delayed(const Duration(milliseconds: 100), () {
                // Check if widget is still mounted (not disposed)
                if (mounted) {
                  // Call the reloadFavorites method on FavoritesScreen
                  (_favoritesKey.currentState as dynamic).reloadFavorites();
                }
              });
            }
          });
        },
        selectedItemColor: Colors.red, // Active tab color (Pokémon red!)
        unselectedItemColor: Colors.grey, // Inactive tab color
        type: BottomNavigationBarType.fixed, // Keep all labels visible
        elevation: 8, // Shadow under the bar
        items: const [
          // Tab 0: Cards (Browse all cards)
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Cards',
          ),
          // Tab 1: Battle (Compare cards)
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi),
            label: 'Battle',
          ),
          // Tab 2: Favorites (Saved cards)
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          // Tab 3: Settings (App preferences)
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
