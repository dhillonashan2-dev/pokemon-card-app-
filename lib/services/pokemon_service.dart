// Import dart:convert for JSON parsing
import 'dart:convert';
// Import http package for making API requests
import 'package:http/http.dart' as http;
// Import our PokemonCard model
import '../models/pokemon_card.dart';

// Service class to handle API calls to Pokémon TCG API
// This is the "middleman" between our app and the internet
class PokemonService {
  // Base URL for the Pokémon TCG API (Version 2)
  // This is the main address where we get card data from
  static const String baseUrl = 'https://api.pokemontcg.io/v2';
  
  // Generate 300 sample Pokémon cards as fallback data
  // This ensures the app works even when offline or if the API is down
  List<PokemonCard> _getSampleCards() {
    // Create an empty list to store all our cards
    final List<PokemonCard> cards = [];
    
    // Generate Base Set cards (102 cards from the original 1999 set)
    // Loop from 1 to 102 to create each card
    for (int i = 1; i <= 102; i++) {
      cards.add(PokemonCard(
        id: 'base1-$i', // Unique ID like "base1-1", "base1-2", etc.
        name: _getPokemonName(i), // Get name from helper function
        imageUrl: 'https://images.pokemontcg.io/base1/$i.png', // Small image URL
        largeImageUrl: 'https://images.pokemontcg.io/base1/${i}_hires.png', // High-res image
        type: _getPokemonType(i), // Assign a type (Fire, Water, etc.)
        rarity: _getRarity(i), // Assign rarity (Common, Rare, etc.)
      ));
    }
    
    // Generate Jungle Set cards (64 cards from the 1999 Jungle expansion)
    for (int i = 1; i <= 64; i++) {
      cards.add(PokemonCard(
        id: 'jungle-$i',
        name: _getJunglePokemonName(i), // Different names for Jungle set
        imageUrl: 'https://images.pokemontcg.io/base2/$i.png',
        largeImageUrl: 'https://images.pokemontcg.io/base2/${i}_hires.png',
        type: _getPokemonType(i),
        rarity: _getRarity(i),
      ));
    }
    
    // Generate Fossil Set cards (62 cards from the 1999 Fossil expansion)
    for (int i = 1; i <= 62; i++) {
      cards.add(PokemonCard(
        id: 'fossil-$i',
        name: _getFossilPokemonName(i), // Different names for Fossil set
        imageUrl: 'https://images.pokemontcg.io/base3/$i.png',
        largeImageUrl: 'https://images.pokemontcg.io/base3/${i}_hires.png',
        type: _getPokemonType(i),
        rarity: _getRarity(i),
      ));
    }
    
    // Generate Team Rocket Set cards (72 cards to reach exactly 300 total)
    // 102 + 64 + 62 + 72 = 300 cards
    for (int i = 1; i <= 72; i++) {
      cards.add(PokemonCard(
        id: 'teamrocket-$i',
        name: _getTeamRocketPokemonName(i), // Different names for Team Rocket set
        imageUrl: 'https://images.pokemontcg.io/base4/$i.png',
        largeImageUrl: 'https://images.pokemontcg.io/base4/${i}_hires.png',
        type: _getPokemonType(i),
        rarity: _getRarity(i),
      ));
    }
    
    // Return exactly 300 cards (just in case we generated more)
    return cards.take(300).toList();
  }
  
  // Helper function to get Pokémon names for the Base Set
  // Uses modulo (%) to cycle through names if we run out
  String _getPokemonName(int num) {
    final names = ['Alakazam', 'Blastoise', 'Chansey', 'Charizard', 'Clefairy', 'Gyarados', 'Hitmonchan', 'Machamp', 'Magneton', 'Mewtwo',
                  'Nidoking', 'Ninetales', 'Poliwrath', 'Raichu', 'Venusaur', 'Zapdos', 'Beedrill', 'Dragonair', 'Dugtrio', 'Electabuzz',
                  'Electrode', 'Pidgeotto', 'Arcanine', 'Charmeleon', 'Dewgong', 'Dratini', 'Farfetch\'d', 'Growlithe', 'Haunter', 'Ivysaur',
                  'Jynx', 'Kadabra', 'Kakuna', 'Machoke', 'Magikarp', 'Magmar', 'Nidorino', 'Poliwhirl', 'Porygon', 'Raticate',
                  'Seel', 'Wartortle', 'Abra', 'Bulbasaur', 'Caterpie', 'Charmander', 'Diglett', 'Doduo', 'Drowzee', 'Gastly',
                  'Koffing', 'Machop', 'Magnemite', 'Metapod', 'Nidoran♂', 'Onix', 'Pidgey', 'Pikachu', 'Poliwag', 'Ponyta',
                  'Rattata', 'Sandshrew', 'Squirtle', 'Starmie', 'Staryu', 'Tangela', 'Voltorb', 'Vulpix', 'Weedle', 'Clefairy Doll',
                  'Computer Search', 'Devolution Spray', 'Imposter Professor Oak', 'Item Finder', 'Lass', 'Pokemon Breeder', 'Pokemon Trader', 'Scoop Up', 'Super Energy Removal',
                  'Defender', 'Energy Retrieval', 'Full Heal', 'Maintenance', 'PlusPower', 'Pokemon Center', 'Pokemon Flute', 'Pokedex', 'Professor Oak', 'Revive',
                  'Super Potion', 'Bill', 'Energy Removal', 'Gust of Wind', 'Potion', 'Switch', 'Double Colorless Energy', 'Fighting Energy', 'Fire Energy', 'Grass Energy',
                  'Lightning Energy', 'Psychic Energy'];
    return names[(num - 1) % names.length];
  }
  
  String _getJunglePokemonName(int num) {
    final names = ['Clefable', 'Electrode', 'Flareon', 'Jolteon', 'Kangaskhan', 'Mr. Mime', 'Nidoqueen', 'Pidgeot', 'Pinsir', 'Scyther',
                  'Snorlax', 'Vaporeon', 'Venomoth', 'Victreebel', 'Vileplume', 'Wigglytuff', 'Clefable', 'Electrode', 'Flareon', 'Jolteon',
                  'Kangaskhan', 'Mr. Mime', 'Nidoqueen', 'Pidgeot', 'Pinsir', 'Scyther', 'Snorlax', 'Vaporeon', 'Venomoth', 'Victreebel',
                  'Butterfree', 'Dodrio', 'Exeggutor', 'Fearow', 'Gloom', 'Lickitung', 'Marowak', 'Nidorina', 'Parasect', 'Persian',
                  'Primeape', 'Rapidash', 'Rhydon', 'Seaking', 'Tauros', 'Weepinbell', 'Bellsprout', 'Cubone', 'Eevee', 'Exeggcute',
                  'Goldeen', 'Jigglypuff', 'Mankey', 'Meowth', 'Nidoran♀', 'Oddish', 'Paras', 'Pikachu', 'Rhyhorn', 'Spearow',
                  'Venonat', 'Poke Ball', 'Potion', 'Energy'];
    return names[(num - 1) % names.length];
  }
  
  String _getFossilPokemonName(int num) {
    final names = ['Aerodactyl', 'Articuno', 'Ditto', 'Dragonite', 'Gengar', 'Haunter', 'Hitmonlee', 'Hypno', 'Kabutops', 'Lapras',
                  'Magneton', 'Moltres', 'Muk', 'Raichu', 'Zapdos', 'Aerodactyl', 'Articuno', 'Ditto', 'Dragonite', 'Gengar',
                  'Arbok', 'Cloyster', 'Gastly', 'Golbat', 'Golduck', 'Golem', 'Graveler', 'Kingler', 'Magmar', 'Omastar',
                  'Sandslash', 'Seadra', 'Slowbro', 'Tentacruel', 'Weezing', 'Ekans', 'Geodude', 'Grimer', 'Horsea', 'Kabuto',
                  'Krabby', 'Omanyte', 'Psyduck', 'Shellder', 'Slowpoke', 'Tentacool', 'Zubat', 'Mr. Fuji', 'Energy Search', 'Gambler',
                  'Recycle', 'Mysterious Fossil', 'Energy'];
    return names[(num - 1) % names.length];
  }
  
  String _getTeamRocketPokemonName(int num) {
    final names = ['Dark Alakazam', 'Dark Arbok', 'Dark Blastoise', 'Dark Charizard', 'Dark Dragonite', 'Dark Dugtrio', 'Dark Golbat', 'Dark Gyarados', 'Dark Hypno', 'Dark Machamp',
                  'Dark Magneton', 'Dark Slowbro', 'Dark Vileplume', 'Dark Weezing', 'Here Comes Team Rocket!', 'Rocket\'s Sneak Attack', 'Dark Alakazam', 'Dark Arbok', 'Dark Blastoise', 'Dark Charizard',
                  'Dark Charmeleon', 'Dark Dragonair', 'Dark Electrode', 'Dark Flareon', 'Dark Gloom', 'Dark Golduck', 'Dark Jolteon', 'Dark Kadabra', 'Dark Machoke', 'Dark Magneton',
                  'Dark Muk', 'Dark Persian', 'Dark Primeape', 'Dark Rapidash', 'Dark Vaporeon', 'Dark Wartortle', 'Magikarp', 'Dark Raticate', 'Dark Charmeleon', 'Dark Dragonair',
                  'Dark Abra', 'Dark Charmander', 'Dark Dragonite', 'Dark Drowzee', 'Dark Dugtrio', 'Dark Ekans', 'Dark Grimer', 'Dark Growlithe', 'Dark Haunter', 'Dark Ivysaur',
                  'Dark Jynx', 'Dark Kadabra', 'Dark Kakuna', 'Dark Machop', 'Dark Magikarp', 'Dark Magmar', 'Dark Mankey', 'Dark Meowth', 'Dark Muk', 'Dark Oddish',
                  'Dark Pidgey', 'Dark Pikachu', 'Dark Poliwag', 'Dark Ponyta', 'Dark Psyduck', 'Dark Raticate', 'Dark Rattata', 'Dark Slowpoke', 'Dark Squirtle', 'Dark Voltorb',
                  'Dark Weedle', 'Dark Zubat'];
    return names[(num - 1) % names.length];
  }
  
  // Helper function to assign a type to each card
  // Uses modulo (%) to cycle through the 10 different Pokémon types
  String _getPokemonType(int num) {
    final types = ['Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Fighting', 'Colorless', 'Dragon', 'Dark', 'Steel'];
    return types[num % types.length]; // Cycle through types based on card number
  }
  
  // Helper function to assign rarity to each card
  // More common cards appear more frequently
  String _getRarity(int num) {
    if (num % 15 == 0) return 'Rare Holo'; // Every 15th card is holographic
    if (num % 7 == 0) return 'Rare'; // Every 7th card is rare
    if (num % 3 == 0) return 'Uncommon'; // Every 3rd card is uncommon
    return 'Common'; // All other cards are common
  }

  // Main function to fetch Pokémon cards from the API
  // Parameters:
  //   - page: Which page of results to get (default: 1)
  //   - pageSize: How many cards per page (default: 20)
  //   - useFallback: Whether to skip API and use sample cards (default: false)
  Future<List<PokemonCard>> fetchCards({int page = 1, int pageSize = 20, bool useFallback = false}) async {
    // If user requested fallback mode, return sample cards immediately
    if (useFallback) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return _getSampleCards();
    }
    
    try {
      // Build the API URL with page and pageSize parameters
      // Example: https://api.pokemontcg.io/v2/cards?page=1&pageSize=20
      final url = Uri.parse('$baseUrl/cards?page=$page&pageSize=$pageSize');

      // Make the HTTP GET request to the API
      // Set a 15-second timeout in case the internet is slow
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(); // Throw error if it takes too long
        },
      );

      // Check if the request was successful (status code 200 = success)
      if (response.statusCode == 200) {
        // Parse the JSON response into a Dart map
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Extract the 'data' array from the response (this contains the cards)
        final List<dynamic> cardsJson = jsonData['data'] ?? [];

        // Convert each JSON object to a PokemonCard object
        // .map() transforms each item in the list
        final cards = cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
        return cards; // Return the list of cards
      } else if (response.statusCode == 504 || response.statusCode == 503) {
        // Server is down or overloaded
        throw Exception('The Pokémon server is busy right now. Showing sample cards instead.');
      } else if (response.statusCode == 429) {
        // Too many requests (rate limited)
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else {
        // Any other error
        throw Exception('Failed to load cards (Error ${response.statusCode}). Please try again.');
      }
    } on TimeoutException {
      // If the request times out, return sample cards instead
      return _getSampleCards();
    } catch (e) {
      // Check if it's a network-related error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('timeout') ||
          e.toString().contains('504') ||
          e.toString().contains('503')) {
        // Network issue detected, use sample cards as backup
        return _getSampleCards();
      }
      
      // If it's a different type of error, throw it again
      rethrow;
    }
  }

  // Search for cards by name (bonus feature - not currently used in UI)
  // This allows searching the API for specific Pokémon
  Future<List<PokemonCard>> searchCards(String query) async {
    try {
      // Build search URL with query parameter
      // The asterisk (*) allows partial matches
      final url = Uri.parse('$baseUrl/cards?q=name:$query*');
      final response = await http.get(url);

      // If successful, parse and return the results
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> cardsJson = jsonData['data'] ?? [];
        return cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
      } else {
        throw Exception('Failed to search cards');
      }
    } catch (e) {
      throw Exception('Error searching cards: $e');
    }
  }
}

class TimeoutException implements Exception {}
