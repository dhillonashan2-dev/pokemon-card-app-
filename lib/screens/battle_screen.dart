import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_card.dart';
import '../services/pokemon_service.dart';
import '../services/favorites_service.dart';

class BattleScreen extends StatefulWidget {
  final ThemeMode themeMode;
  
  const BattleScreen({super.key, required this.themeMode});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  final PokemonService _pokemonService = PokemonService();
  final FavoritesService _favoritesService = FavoritesService();
  
  List<PokemonCard> _allCards = [];
  PokemonCard? _selectedCard1;
  PokemonCard? _selectedCard2;
  bool _isLoading = true;
  Set<String> _favoriteIds = {};
  
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
    
    _loadCards();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _pokemonService.fetchCards(pageSize: 300, useFallback: true);
      final favoriteIds = await _favoritesService.getFavoriteIds();
      
      setState(() {
        _allCards = cards;
        _favoriteIds = favoriteIds.toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCard(int position) async {
    final selected = await showDialog<PokemonCard>(
      context: context,
      builder: (context) => _CardSelectionDialog(cards: _allCards, themeMode: widget.themeMode),
    );
    
    if (selected != null) {
      setState(() {
        if (position == 1) {
          _selectedCard1 = selected;
        } else {
          _selectedCard2 = selected;
        }
      });
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
              title: const Text('Battle'),
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
                          Text('Loading cards...'),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Card 1
                            Expanded(
                              child: _buildCardSlot(1, _selectedCard1),
                            ),
                            // VS Badge
                            Container(
                              width: 60,
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Card 2
                            Expanded(
                              child: _buildCardSlot(2, _selectedCard2),
                            ),
                          ],
                        ),
                      ),
                      // Comparison Stats
                      if (_selectedCard1 != null && _selectedCard2 != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.all(16),
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
                              const Text(
                                'Comparison',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildComparisonRow('Type', _selectedCard1!.type ?? 'Unknown', _selectedCard2!.type ?? 'Unknown'),
                              const SizedBox(height: 8),
                              _buildComparisonRow('Rarity', _selectedCard1!.rarity ?? 'Common', _selectedCard2!.rarity ?? 'Common'),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCardSlot(int position, PokemonCard? card) {
    final isDark = widget.themeMode == ThemeMode.dark;
    
    return GestureDetector(
      onTap: () => _selectCard(position),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? Colors.grey[850] : Colors.white)?.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: card == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Card $position',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CachedNetworkImage(
                              imageUrl: card.largeImageUrl ?? card.imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              _favoriteIds.contains(card.id) ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final isFavorite = await _favoritesService.toggleFavorite(card.id);
                              setState(() {
                                if (isFavorite) {
                                  _favoriteIds.add(card.id);
                                } else {
                                  _favoriteIds.remove(card.id);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(card.type ?? 'Colorless').withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
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
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value1, String value2) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value1,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value2,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
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

class _CardSelectionDialog extends StatefulWidget {
  final List<PokemonCard> cards;
  final ThemeMode themeMode;
  
  const _CardSelectionDialog({required this.cards, required this.themeMode});

  @override
  State<_CardSelectionDialog> createState() => _CardSelectionDialogState();
}

class _CardSelectionDialogState extends State<_CardSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<PokemonCard> _filteredCards = [];

  @override
  void initState() {
    super.initState();
    _filteredCards = widget.cards;
    _searchController.addListener(_filterCards);
  }

  void _filterCards() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCards = widget.cards;
      } else {
        _filteredCards = widget.cards.where((card) {
          return card.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Select a Card',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _filteredCards.length,
                itemBuilder: (context, index) {
                  final card = _filteredCards[index];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, card),
                    child: Card(
                      elevation: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: card.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              card.name,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
