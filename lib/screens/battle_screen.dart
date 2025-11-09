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

class _BattleScreenState extends State<BattleScreen> {
  final PokemonService _pokemonService = PokemonService();
  final FavoritesService _favoritesService = FavoritesService();
  
  List<PokemonCard> _allCards = [];
  PokemonCard? _selectedCard1;
  PokemonCard? _selectedCard2;
  bool _isLoading = true;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadCards();
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

  // NEW FEATURE: Load two random cards and compare HP (Assignment requirement)
  // This implements: "Use the Pokémon TCG API to load two random pictures"
  // and "Check the HP for each picture and declare the winner among the two cards"
  void _loadRandomBattle() {
    if (_allCards.isEmpty) return;
    
    // Get two random cards from the loaded cards
    _allCards.shuffle();
    final card1 = _allCards[0];
    final card2 = _allCards[1];
    
    setState(() {
      _selectedCard1 = card1;
      _selectedCard2 = card2;
    });
    
    // Show winner announcement after cards are displayed
    Future.delayed(const Duration(milliseconds: 500), () {
      _showWinnerDialog();
    });
  }

  // Show dialog announcing the winner based on HP comparison
  void _showWinnerDialog() {
    if (_selectedCard1 == null || _selectedCard2 == null) return;
    
    // Parse HP values (default to 0 if HP is null or invalid)
    final hp1 = int.tryParse(_selectedCard1!.hp ?? '0') ?? 0;
    final hp2 = int.tryParse(_selectedCard2!.hp ?? '0') ?? 0;
    
    // Determine winner based on HP comparison
    String winner;
    String message;
    
    if (hp1 > hp2) {
      winner = _selectedCard1!.name;
      message = '${_selectedCard1!.name} wins with higher HP!';
    } else if (hp2 > hp1) {
      winner = _selectedCard2!.name;
      message = '${_selectedCard2!.name} wins with higher HP!';
    } else {
      winner = 'Tie';
      message = 'It\'s a tie! Both cards have equal HP.';
    }
    
    // Show winner announcement dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            const SizedBox(width: 8),
            Text(winner == 'Tie' ? 'Tie Game!' : 'Winner!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Show HP comparison
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _selectedCard1!.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'HP: ${hp1}',
                              style: TextStyle(
                                fontSize: 16,
                                color: hp1 > hp2 ? Colors.green : (hp1 == hp2 ? Colors.orange : Colors.red),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _selectedCard2!.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'HP: ${hp2}',
                              style: TextStyle(
                                fontSize: 16,
                                color: hp2 > hp1 ? Colors.green : (hp1 == hp2 ? Colors.orange : Colors.red),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _loadRandomBattle(); // Battle again!
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Battle Again!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    
    // Stable gradient background - no animation
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                Colors.deepPurple.shade900,
                Colors.indigo.shade800,
                Colors.blue.shade900,
              ]
            : [
                Colors.red.shade400,
                Colors.orange.shade300,
                Colors.amber.shade200,
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
                colors: isDark
                  ? [
                      Colors.deepPurple.shade800.withOpacity(0.8),
                      Colors.indigo.shade700.withOpacity(0.8),
                    ]
                  : [
                      Colors.red.shade600.withOpacity(0.8),
                      Colors.orange.shade500.withOpacity(0.8),
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
                      
                      // NEW: Random Battle Button (Assignment requirement)
                      // This implements: "Add a button to your application. Clicking this button will load two random pictures again"
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _loadRandomBattle,
                              icon: const Icon(Icons.shuffle, size: 24),
                              label: const Text(
                                'Random Battle!',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Load 2 random cards and compare HP',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
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
