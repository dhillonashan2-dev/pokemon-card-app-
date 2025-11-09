// Model class to represent a Pokémon card
// This is like a blueprint that defines what information each card contains
class PokemonCard {
  // Unique identifier for the card (e.g., "base1-1")
  final String id;
  
  // Name of the Pokémon (e.g., "Charizard", "Pikachu")
  final String name;
  
  // URL to the small card image (used in lists)
  final String imageUrl;
  
  // URL to the large high-res image (used in detail view)
  // Optional (?) because not all cards have a large image
  final String? largeImageUrl;
  
  // Type of Pokémon (e.g., "Fire", "Water", "Grass")
  // Optional because some cards might not have a type
  final String? type;
  
  // How rare the card is (e.g., "Common", "Rare", "Holo Rare")
  // Optional because not all cards specify rarity
  final String? rarity;

  // HP (Hit Points) of the Pokémon (e.g., "120", "60")
  // Optional because not all cards have HP (like Trainer cards)
  final String? hp;

  // Set name (e.g., "Base", "Jungle", "Fossil")
  // Optional because not all cards specify set name
  final String? setName;

  // Constructor: Creates a new PokemonCard object
  // Required fields must be provided, optional fields can be null
  PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.largeImageUrl,
    this.type,
    this.rarity,
    this.hp,
    this.setName,
  });

  // Factory constructor: Creates a PokemonCard from JSON data
  // This is used when we receive card data from the API
  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    try {
      return PokemonCard(
        // Get the ID from JSON, use empty string if not found
        id: json['id'] ?? '',
        
        // Get the name, use "Unknown" if not found
        name: json['name'] ?? 'Unknown',
        
        // Get the small image URL from nested 'images' object
        // Use placeholder image if not found
        imageUrl: json['images']?['small'] ?? 'https://via.placeholder.com/200',
        
        // Get large image URL, fall back to small image if not available
        largeImageUrl: json['images']?['large'] ?? json['images']?['small'] ?? 'https://via.placeholder.com/400',
        
        // Get the first type from the types array
        // Some Pokémon have multiple types, we only take the first one
        type: (json['types'] != null && json['types'].isNotEmpty) ? json['types'][0] : null,
        
        // Get the rarity, use empty string if not found
        rarity: json['rarity'] ?? '',
        
        // Get the HP value (important for battle comparisons!)
        hp: json['hp'],
        
        // Get the set name from the nested 'set' object
        setName: json['set']?['name'],
      );
    } catch (e) {
      // If something goes wrong while parsing, re-throw the error
      // so the caller knows something went wrong
      rethrow;
    }
  }
}
