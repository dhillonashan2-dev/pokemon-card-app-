import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

void main() {
  runApp(const PokemonBattleApp());
}

class PokemonBattleApp extends StatelessWidget {
  const PokemonBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Card Battle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const BattleScreen(),
    );
  }
}

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  // Store the two cards being compared
  Map<String, dynamic>? card1;
  Map<String, dynamic>? card2;
  bool isLoading = false;
  String? winner;
  
  @override
  void initState() {
    super.initState();
    // Load cards when app starts
    loadRandomCards();
  }
  
  // Function to fetch a random card from the Pokémon TCG API
  Future<Map<String, dynamic>> fetchRandomCard() async {
    try {
      // Generate a random page number between 1 and 50
      final random = Random();
      final randomPage = random.nextInt(50) + 1;
      
      // Fetch cards from the API
      final response = await http.get(
        Uri.parse('https://api.pokemontcg.io/v2/cards?page=$randomPage&pageSize=1')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cards = data['data'] as List;
        
        if (cards.isNotEmpty) {
          return cards[0] as Map<String, dynamic>;
        }
      }
      
      // Return a fallback card if API fails
      return {
        'name': 'Unknown Card',
        'hp': '0',
        'images': {'large': 'https://via.placeholder.com/400'}
      };
    } catch (e) {
      // Return fallback card on error
      return {
        'name': 'Error Loading Card',
        'hp': '0',
        'images': {'large': 'https://via.placeholder.com/400'}
      };
    }
  }
  
  // Function to load two random cards and compare them
  Future<void> loadRandomCards() async {
    setState(() {
      isLoading = true;
      winner = null;
    });
    
    // Fetch two random cards from the API
    final fetchedCard1 = await fetchRandomCard();
    final fetchedCard2 = await fetchRandomCard();
    
    // Get HP values (default to 0 if HP is null or invalid)
    final hp1 = int.tryParse(fetchedCard1['hp']?.toString() ?? '0') ?? 0;
    final hp2 = int.tryParse(fetchedCard2['hp']?.toString() ?? '0') ?? 0;
    
    // Determine the winner based on HP comparison
    String result;
    if (hp1 > hp2) {
      result = '${fetchedCard1['name']} wins!';
    } else if (hp2 > hp1) {
      result = '${fetchedCard2['name']} wins!';
    } else {
      result = 'It\'s a tie!';
    }
    
    setState(() {
      card1 = fetchedCard1;
      card2 = fetchedCard2;
      winner = result;
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Card Battle'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Display the two cards side by side
                  Row(
                    children: [
                      // Card 1
                      Expanded(
                        child: _buildCard(card1, 'Card 1'),
                      ),
                      const SizedBox(width: 16),
                      // VS text in the middle
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Card 2
                      Expanded(
                        child: _buildCard(card2, 'Card 2'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Display winner
                  if (winner != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Text(
                        winner!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 30),
                  
                  // Button to load new cards and battle again
                  ElevatedButton.icon(
                    onPressed: loadRandomCards,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Battle Again!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  // Helper function to build a card display
  Widget _buildCard(Map<String, dynamic>? card, String label) {
    if (card == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final name = card['name'] ?? 'Unknown';
    final hp = card['hp'] ?? '?';
    final imageUrl = card['images']?['small'] ?? 'https://via.placeholder.com/200';
    
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Card image
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Card name
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // HP value
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'HP: $hp',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
