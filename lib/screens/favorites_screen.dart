import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_card.dart';
import '../services/pokemon_service.dart';
import '../services/favorites_service.dart';
import 'card_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final ThemeMode themeMode;
  
  const FavoritesScreen({super.key, required this.themeMode});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  final PokemonService _pokemonService = PokemonService();
  final FavoritesService _favoritesService = FavoritesService();
  
  List<PokemonCard> _favoriteCards = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
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
    
    _loadFavorites();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load all cards
      final cards = await _pokemonService.fetchCards(pageSize: 300, useFallback: true);
      
      // Get favorite IDs
      final favoriteIds = await _favoritesService.getFavoriteIds();
      
      // Filter favorite cards
      final favorites = cards.where((card) => favoriteIds.contains(card.id)).toList();
      
      if (!mounted) return;
      
      setState(() {
        _favoriteCards = favorites;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  // Public method to reload favorites from outside
  void reloadFavorites() {
    _loadFavorites();
  }
  
  Future<void> _removeFavorite(PokemonCard card) async {
    await _favoritesService.removeFavorite(card.id);
    await _loadFavorites();
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
              title: const Text('Favorites'),
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
                          Text('Loading favorites...'),
                        ],
                      ),
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error: $_errorMessage',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadFavorites,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _favoriteCards.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 64,
                                    color: Colors.red.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No favorite cards yet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap the heart icon on cards to add them to favorites',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadFavorites,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _favoriteCards.length,
                              itemBuilder: (context, index) {
                                return _buildFavoriteCard(_favoriteCards[index], index);
                              },
                            ),
                          ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteCard(PokemonCard card, int index) {
    final isDark = widget.themeMode == ThemeMode.dark;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              color: (isDark ? Colors.grey[800] : Colors.white)?.withOpacity(0.9),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardDetailScreen(card: card),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Card image
                      Hero(
                        tag: card.id,
                        child: Container(
                          width: 80,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: _getTypeColor(card.type ?? 'Colorless').withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: card.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Card info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getTypeColor(card.type ?? 'Colorless'),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                card.type ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.rarity ?? 'Common',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Remove favorite button
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _removeFavorite(card),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow[700]!;
      case 'psychic':
        return Colors.purple;
      case 'fighting':
        return Colors.red[900]!;
      case 'colorless':
        return Colors.grey;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.brown;
      case 'steel':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
