import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/pokemon_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;
  
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final FavoritesService _favoritesService = FavoritesService();
  final PokemonService _pokemonService = PokemonService();
  
  int _favoriteCount = 0;
  int _totalCards = 0;
  bool _isLoading = true;
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    
    _loadStats();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavoriteIds();
      final cards = await _pokemonService.fetchCards(pageSize: 300, useFallback: true);
      
      setState(() {
        _favoriteCount = favorites.length;
        _totalCards = cards.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites?'),
        content: const Text('Are you sure you want to remove all favorite cards? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _favoritesService.saveFavorites([]);
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All favorites cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final color1 = isDark ? Colors.deepPurple : Colors.red;
        final color2 = isDark ? Colors.blue : Colors.orange;
        final color3 = isDark ? Colors.teal : Colors.yellow;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color1, color2, _animation.value)!,
                Color.lerp(color2, color3, _animation.value)!,
                Color.lerp(color3, color1, _animation.value)!,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Settings'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(color1, color2, _animation.value)!.withOpacity(0.8),
                      Color.lerp(color2, color3, _animation.value)!.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            body: _isLoading
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading settings...'),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistics Card
                        _buildStatisticsCard(isDark),
                        const SizedBox(height: 16),
                        
                        // Appearance Section
                        _buildSectionHeader('Appearance', Icons.palette),
                        const SizedBox(height: 8),
                        _buildThemeCard(isDark),
                        const SizedBox(height: 16),
                        
                        // Data Management Section
                        _buildSectionHeader('Data Management', Icons.storage),
                        const SizedBox(height: 8),
                        _buildDataCard(isDark),
                        const SizedBox(height: 16),
                        
                        // Share & Social Section
                        _buildSectionHeader('Share & Social', Icons.share),
                        const SizedBox(height: 8),
                        _buildShareCard(isDark),
                        const SizedBox(height: 16),
                        
                        // About Section
                        _buildSectionHeader('About', Icons.info_outline),
                        const SizedBox(height: 8),
                        _buildAboutCard(isDark),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850] : Colors.white)?.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Your Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Cards',
                _totalCards.toString(),
                Icons.style,
                Colors.orange,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[300],
              ),
              _buildStatItem(
                'Favorites',
                _favoriteCount.toString(),
                Icons.favorite,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850] : Colors.white)?.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.purple : Colors.orange,
            ),
            title: const Text('Theme Mode'),
            subtitle: Text(isDark ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) => widget.onThemeToggle(),
              activeTrackColor: Colors.purple,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.amber),
            title: const Text('Animated Background'),
            subtitle: const Text('Colorful gradient animation'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850] : Colors.white)?.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.blue),
            title: const Text('Refresh Data'),
            subtitle: const Text('Reload all cards'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await _loadStats();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data refreshed'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text('Clear Favorites'),
            subtitle: Text('Remove all $_favoriteCount favorites'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _favoriteCount > 0 ? _clearAllFavorites : null,
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850] : Colors.white)?.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: const Text('Share App'),
            subtitle: const Text('Share this app with friends'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.share, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Share App'),
                    ],
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Share this awesome Pokémon Cards app with your friends!'),
                      SizedBox(height: 16),
                      Text(
                        'GitHub: github.com/dhillonashan2-dev/pokemon-card-app-',
                        style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Link'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.green),
            title: const Text('Invite Friends'),
            subtitle: const Text('Challenge friends to collect cards'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.people, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Invite Friends'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Hey! Check out this cool Pokémon Cards app!'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✨ 300+ Pokémon cards'),
                            Text('⚔️ Battle mode with HP comparison'),
                            Text('💖 Save your favorite cards'),
                            Text('🔍 Search and filter by type'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Rate App'),
            subtitle: Text('You have $_favoriteCount favorite cards!'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Rate This App'),
                    ],
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Enjoying the app?'),
                      SizedBox(height: 8),
                      Text('Give us a star on GitHub! ⭐'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Maybe Later'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thanks for your support! 🎉'),
                            backgroundColor: Colors.amber,
                          ),
                        );
                      },
                      icon: const Icon(Icons.star),
                      label: const Text('Rate Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850] : Colors.white)?.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.red,
            child: Icon(Icons.catching_pokemon, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pokémon Cards App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.api, color: Colors.blue),
            title: const Text('Pokémon TCG API'),
            subtitle: const Text('pokemontcg.io'),
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.collections, color: Colors.orange),
            title: const Text('Total Collection'),
            subtitle: const Text('300 Pokémon Cards'),
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Features'),
            subtitle: const Text('Browse, Battle, Favorites'),
            dense: true,
          ),
        ],
      ),
    );
  }
}
