// Import Flutter material design library for UI components
import 'package:flutter/material.dart';
// Import the home screen which contains the main navigation
import 'screens/home_screen.dart';

// Main entry point of the application
// This is the first function that runs when the app starts
void main() {
  runApp(const MyApp()); // Launch the app with MyApp widget
}

// MyApp is the root widget of the application
// StatefulWidget allows the app to manage theme changes dynamically
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// State class for MyApp that handles theme switching
class _MyAppState extends State<MyApp> {
  // Track the current theme mode (light or dark)
  // Default is light mode
  ThemeMode _themeMode = ThemeMode.light;

  // Function to toggle between light and dark theme
  // Called from the settings screen when user switches the theme toggle
  void _toggleTheme() {
    setState(() {
      // Switch between light and dark mode
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Cards App', // App name shown in task switcher
      debugShowCheckedModeBanner: false, // Hide debug banner in corner
      themeMode: _themeMode, // Current theme mode (light/dark)
      
      // Light theme configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red, // Base color (Pokémon red!)
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Use latest Material Design 3
        scaffoldBackgroundColor: Colors.grey[100], // Background for all screens
      ),
      
      // Dark theme configuration
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red, // Same base color for consistency
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[900], // Dark background
        cardColor: Colors.grey[850], // Darker cards for better contrast
      ),
      
      // Set the home screen as the first page users see
      // Pass the theme toggle function so settings can change theme
      home: HomeScreen(onThemeToggle: _toggleTheme, themeMode: _themeMode),
    );
  }
}
