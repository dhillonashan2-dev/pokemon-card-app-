// Import SharedPreferences for local storage (saves data on device)
import 'package:shared_preferences/shared_preferences.dart';
// Import our PokemonCard model
import '../models/pokemon_card.dart';

// Service class to manage favorite Pokémon cards with persistent storage
// This ensures favorites are saved even when the app is closed
class FavoritesService {
  // Key used to store/retrieve favorites from SharedPreferences
  // Think of it like a label on a storage box
  static const String _favoritesKey = 'favorite_cards';
  
  // Save a list of favorite cards to local storage
  // Takes a list of PokemonCard objects and stores their IDs
  Future<void> saveFavorites(List<PokemonCard> favorites) async {
    // Get access to the device's local storage
    final prefs = await SharedPreferences.getInstance();
    
    // Extract just the IDs from the cards (we only store IDs, not entire cards)
    final List<String> favoriteIds = favorites.map((card) => card.id).toList();
    
    // Save the list of IDs to storage
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }
  
  // Get the list of favorite card IDs from storage
  // Returns an empty list if no favorites exist yet
  Future<List<String>> getFavoriteIds() async {
    // Get access to local storage
    final prefs = await SharedPreferences.getInstance();
    
    // Retrieve the saved IDs, or return empty list if nothing saved yet
    return prefs.getStringList(_favoritesKey) ?? [];
  }
  
  // Add a card to favorites
  // Only adds if it's not already in favorites (prevents duplicates)
  Future<void> addFavorite(String cardId) async {
    // Get current list of favorite IDs
    final favoriteIds = await getFavoriteIds();
    
    // Only add if this card isn't already favorited
    if (!favoriteIds.contains(cardId)) {
      favoriteIds.add(cardId); // Add the new card ID to the list
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favoriteIds); // Save updated list
    }
  }
  
  // Remove a card from favorites
  Future<void> removeFavorite(String cardId) async {
    // Get current list of favorites
    final favoriteIds = await getFavoriteIds();
    
    // Remove this card's ID from the list
    favoriteIds.remove(cardId);
    
    // Save the updated list back to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }
  
  // Check if a specific card is in favorites
  // Returns true if favorited, false if not
  Future<bool> isFavorite(String cardId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(cardId); // Check if ID exists in the list
  }
  
  // Toggle favorite status (add if not favorited, remove if already favorited)
  // Returns true if card is now favorited, false if removed from favorites
  Future<bool> toggleFavorite(String cardId) async {
    // Check current favorite status
    final isFav = await isFavorite(cardId);
    
    if (isFav) {
      // Already favorited, so remove it
      await removeFavorite(cardId);
      return false; // Now not favorited
    } else {
      // Not favorited yet, so add it
      await addFavorite(cardId);
      return true; // Now favorited
    }
  }
}
