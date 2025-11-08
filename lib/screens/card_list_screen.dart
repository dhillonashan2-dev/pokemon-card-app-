import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_card.dart';
import '../services/pokemon_service.dart';
import '../services/favorites_service.dart';
import 'card_detail_screen.dart';

// Main screen that displays a list of Pokémon cards
class CardListScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  
  const CardListScreen({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> with SingleTickerProviderStateMixin {
  final PokemonService _pokemonService = PokemonService();
  List<PokemonCard> _cards = [];
  List<PokemonCard> _filteredCards = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Set<String> _favoriteIds = {};
  String? _selectedType;
  
  // Animation controller for gradient
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchController.addListener(_filterCards);
    
    // Initialize animation for gradient
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCards() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCards = _cards.where((card) {
        final matchesSearch = query.isEmpty || card.name.toLowerCase().contains(query);
        final matchesType = _selectedType == null || card.type?.toLowerCase() == _selectedType?.toLowerCase();
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  // Load cards from the API
  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load 300 cards using fallback
      final cards = await _pokemonService.fetchCards(pageSize: 300, useFallback: true);
      
      // Load favorite IDs
      final favoritesService = FavoritesService();
      final favoriteIds = await favoritesService.getFavoriteIds();
      
      if (!mounted) return;
      
      setState(() {
        _cards = cards;
        _filteredCards = cards;
        _favoriteIds = favoriteIds.toSet();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        // Format error message to be more user-friendly
        String errorMsg = e.toString();
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.replaceFirst('Exception:', '').trim();
        }
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                ? [
                    Color.lerp(Colors.purple[900], Colors.blue[900], _animation.value)!,
                    Color.lerp(Colors.blue[900], Colors.teal[900], _animation.value)!,
                    Color.lerp(Colors.teal[900], Colors.purple[900], _animation.value)!,
                  ]
                : [
                    Color.lerp(Colors.red[300], Colors.orange[300], _animation.value)!,
                    Color.lerp(Colors.orange[300], Colors.yellow[300], _animation.value)!,
                    Color.lerp(Colors.yellow[300], Colors.red[300], _animation.value)!,
                  ],
            ),
          ),
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                  ? [Colors.purple[800]!, Colors.blue[800]!]
                  : [Colors.red, Colors.orange],
              ),
            ),
          ),
          title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search Pokémon...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : const Text('Cards'),
          foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
            tooltip: _isSearching ? 'Close Search' : 'Search',
          ),
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.light 
                ? Icons.dark_mode 
                : Icons.light_mode
            ),
            onPressed: widget.onThemeToggle,
            tooltip: widget.themeMode == ThemeMode.light 
              ? 'Dark Mode' 
              : 'Light Mode',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCards,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Type filter chips
          if (_isSearching)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildTypeChip('All', null),
                  _buildTypeChip('Fire', 'Fire'),
                  _buildTypeChip('Water', 'Water'),
                  _buildTypeChip('Grass', 'Grass'),
                  _buildTypeChip('Electric', 'Electric'),
                  _buildTypeChip('Psychic', 'Psychic'),
                  _buildTypeChip('Fighting', 'Fighting'),
                  _buildTypeChip('Colorless', 'Colorless'),
                  _buildTypeChip('Dragon', 'Dragon'),
                  _buildTypeChip('Dark', 'Dark'),
                  _buildTypeChip('Steel', 'Steel'),
                ],
              ),
            ),
          // Show banner when using sample cards
          if (_cards.length == 20 && !_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing 20 sample cards (API unavailable). Pull down to retry.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCards,
              child: _buildBody(),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBody() {
    // Show loading indicator
    if (_isLoading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading Pokémon cards...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    // Show error message
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                child: const Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Connection Issue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCards,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tips:\n• Check your internet connection\n• The Pokémon API might be busy\n• Try again in a few seconds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          ),
        ),
      );
    }

    // Show empty state
    if (_cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No cards found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCards,
              child: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    // Show list of cards
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredCards.length,
      itemBuilder: (context, index) {
        final card = _filteredCards[index];
        return _buildCardItem(card, index);
      },
    );
  }

  Widget _buildCardItem(PokemonCard card, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        elevation: 8,
        color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]!.withOpacity(0.9)
          : Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to detail screen when card is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailScreen(card: card),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]!
                    : Colors.white,
                  _getTypeColor(card.type ?? '').withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Card image with shadow
                  Hero(
                    tag: card.id,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _getTypeColor(card.type ?? '').withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: card.imageUrl,
                          width: 100,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 100,
                            height: 140,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 100,
                            height: 140,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card details
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
                        if (card.type != null && card.type!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getTypeColor(card.type!),
                                  _getTypeColor(card.type!).withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _getTypeColor(card.type!).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              card.type!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (card.rarity != null && card.rarity!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  card.rarity!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _favoriteIds.contains(card.id) ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      final favoritesService = FavoritesService();
                      final isFavorite = await favoritesService.toggleFavorite(card.id);
                      setState(() {
                        if (isFavorite) {
                          _favoriteIds.add(card.id);
                        } else {
                          _favoriteIds.remove(card.id);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build type filter chip
  Widget _buildTypeChip(String label, String? type) {
    final isSelected = _selectedType == type;
    final color = type != null ? _getTypeColor(type) : Colors.grey;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
            _filterCards();
          });
        },
        backgroundColor: color.withOpacity(0.2),
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Helper method to get color based on Pokémon type
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
        return Colors.red[800]!;
      case 'darkness':
        return Colors.grey[900]!;
      case 'metal':
        return Colors.grey;
      case 'fairy':
        return Colors.pink;
      case 'dragon':
        return Colors.indigo;
      case 'colorless':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
