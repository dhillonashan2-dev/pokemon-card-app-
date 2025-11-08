// Import Flutter Material Design library
import 'package:flutter/material.dart';
// Import cached image package for efficient image loading
import 'package:cached_network_image/cached_network_image.dart';
// Import our PokemonCard model
import '../models/pokemon_card.dart';

// Card Detail Screen - Shows an enlarged view when user taps on a card
// This is a StatelessWidget because it doesn't need to track any changing state
class CardDetailScreen extends StatelessWidget {
  // The card to display in detail
  final PokemonCard card;

  const CardDetailScreen({super.key, required this.card});

  // Helper function to get the color associated with each Pokémon type
  // This makes Fire types orange, Water types blue, etc.
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orange; // Fire types = orange/red
      case 'water':
        return Colors.blue; // Water types = blue
      case 'grass':
        return Colors.green; // Grass types = green
      case 'electric':
        return Colors.yellow[700]!; // Electric types = yellow
      case 'psychic':
        return Colors.purple; // Psychic types = purple
      case 'fighting':
        return Colors.red[800]!; // Fighting types = dark red
      case 'darkness':
        return Colors.grey[900]!; // Dark types = almost black
      case 'metal':
        return Colors.grey; // Metal types = grey
      case 'fairy':
        return Colors.pink; // Fairy types = pink
      case 'dragon':
        return Colors.indigo; // Dragon types = indigo
      case 'colorless':
        return Colors.brown; // Colorless = brown
      default:
        return Colors.grey; // Unknown types = grey
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the color for this card's type
    final typeColor = _getTypeColor(card.type ?? '');
    
    return Scaffold(
      // Extend body behind the app bar for a more immersive look
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(card.name), // Show Pokémon name in app bar
        backgroundColor: Colors.transparent, // Transparent to show gradient
        elevation: 0, // No shadow
        foregroundColor: Colors.white, // White text and icons
      ),
      body: Container(
        // Create a beautiful gradient background based on the card's type
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              typeColor.withOpacity(0.7), // Darker at top
              typeColor.withOpacity(0.3), // Lighter in middle
              Colors.white, // White at bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // iOS-style bouncy scrolling
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // This is the ENLARGED CARD IMAGE (main feature!)
                // Hero animation makes the card smoothly fly from list to detail screen
                Hero(
                  tag: card.id, // Must match the tag in the list
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    // Add a nice shadow around the card
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: typeColor.withOpacity(0.5), // Shadow color matches type
                          blurRadius: 30, // Soft shadow
                          spreadRadius: 5,
                          offset: const Offset(0, 10), // Shadow below card
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      // CachedNetworkImage loads and caches the image for better performance
                      child: CachedNetworkImage(
                        // Use large image if available, otherwise use regular image
                        imageUrl: card.largeImageUrl ?? card.imageUrl,
                        fit: BoxFit.contain, // Don't stretch the image
                        
                        // Show loading spinner while image is downloading
                        placeholder: (context, url) => Container(
                          width: 300,
                          height: 420,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(), // Spinning loader
                          ),
                        ),
                        
                        // Show error message if image fails to load
                        errorWidget: (context, url, error) => Container(
                          width: 300,
                          height: 420,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64), // Error icon
                              SizedBox(height: 8),
                              Text('Failed to load image'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Card information
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Card Name
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              card.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                            if (card.type != null && card.type!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      typeColor,
                                      typeColor.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: typeColor.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.wb_sunny,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      card.type!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Card Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Card Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (card.rarity != null && card.rarity!.isNotEmpty)
                              _buildDetailRow(
                                Icons.star,
                                'Rarity',
                                card.rarity!,
                                Colors.amber,
                              ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.tag,
                              'Card ID',
                              card.id,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Fun fact section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              typeColor.withOpacity(0.2),
                              typeColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: typeColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.catching_pokemon,
                              size: 48,
                              color: typeColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap the image to view in full detail!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
