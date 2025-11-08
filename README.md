# Pokémon Cards Collection App 🎴

Hey there! Welcome to my Pokémon Cards Collection app. This is a fun little project where you can browse through hundreds of Pokémon cards, save your favorites, and even compare them in battle mode. I built this using Flutter, so it runs smoothly on Windows (and can easily be adapted for mobile too!).

## What's This App About?

Think of this as your personal Pokémon card collection manager. Instead of flipping through binders full of cards, you can browse them digitally, search for specific ones, and keep track of which cards you love the most. It's like having a Pokédex, but for trading cards!

## Cool Features ✨

### 📚 Browse 300+ Cards
The app comes loaded with 300 different Pokémon cards from classic sets like Base Set, Jungle, Fossil, and Team Rocket. Each card shows:
- The Pokémon's picture (high quality images)
- Card name and type (Fire, Water, Grass, etc.)
- HP (hit points) and rarity
- A cute little gradient background based on the Pokémon's type

### 🔍 Smart Search & Filters
Lost in all those cards? No worries! You can:
- **Search by name** - Just start typing and it filters instantly
- **Filter by type** - Want to see only Fire-type Pokémon? Just tap the Fire chip and boom, done!
- The app remembers everything while you're browsing

### 💖 Favorites System
Found a card you absolutely love? Tap that heart icon and it gets saved to your favorites. The best part? Your favorites are saved even after you close the app, so you don't lose them. Go to the Favorites tab to see all your saved cards in one place.

### ⚔️ Battle Mode
This is where it gets fun! You can select two Pokémon cards and compare them side-by-side. See their stats, HP, and types all at once. It's perfect for deciding which card is stronger or just for fun comparisons with friends.

### 🎨 Beautiful Card Details
When you tap on any card, it opens up a gorgeous detail view with:
- A large, high-resolution image of the card
- Smooth Hero animation (the card flies from the list to fullscreen)
- Color-coded background based on the Pokémon's type
- All the card stats displayed nicely

### ⚙️ Settings & Stats
Check out the Settings tab to see:
- **Statistics** - How many cards you've collected and how many are in your favorites
- **Theme Toggle** - Switch between light and dark mode (whatever feels right for you)
- **Data Management** - Refresh the card collection or clear your favorites if needed
- **About Section** - Info about the app version and developer

### 📱 Phone-Style Interface
The app uses a bottom navigation bar just like your favorite mobile apps. Four tabs at the bottom:
- **Cards** - Browse the full collection
- **Battle** - Compare two cards
- **Favorites** - Your saved cards
- **Settings** - App preferences and info

## How Does It Work?

### The Technical Stuff (For The Curious Ones)

The app connects to the **Pokémon TCG API** (the official trading card game database) to fetch real card data. If for some reason the internet isn't working or the API is down, don't worry - the app has 300 backup cards built-in so you can still browse and play around.

Behind the scenes:
- Cards are cached so they load super fast after the first time
- Your favorites are stored locally using SharedPreferences (a simple key-value storage)
- All the animations are smooth thanks to Flutter's animation system
- The window is sized just right (400x800 pixels) to feel like a phone, but you can resize it however you want

## Getting Started 🚀

### What You Need
- **Flutter SDK** (version 3.35.6 or newer)
- **Windows 10 or later** (if running on Windows)
- That's pretty much it!

### How to Run

1. **Clone or download this project** to your computer

2. **Open your terminal** and navigate to the project folder:
   ```
   cd pokemon_cards_app
   ```

3. **Install dependencies**:
   ```
   flutter pub get
   ```

4. **Run the app**:
   ```
   flutter run -d windows
   ```

That's it! The app should launch in a few seconds.

## How to Use the App 💡

### Browsing Cards
1. Open the app - you'll land on the **Cards** tab
2. Scroll through the list to see all available Pokémon cards
3. Use the search bar at the top to find specific cards
4. Tap on the type chips (Fire, Water, Grass, etc.) to filter by type
5. Click on any card to see it in full size with all details

### Saving Favorites
1. See a card you like? Tap the **heart icon** on it
2. The heart turns red - now it's saved!
3. Go to the **Favorites** tab to see all your saved cards
4. Tap the heart again if you want to remove it from favorites

### Battle Mode
1. Go to the **Battle** tab
2. Tap on either of the "Select Card" slots
3. Choose a Pokémon from the grid that pops up
4. Do the same for the second slot
5. Now you can compare their stats side-by-side!

### Changing Settings
1. Head to the **Settings** tab
2. See your collection statistics at the top
3. Toggle dark mode on/off based on your preference
4. Use "Refresh Collection" if you want to reload cards from the API
5. "Clear Favorites" removes all your saved cards (careful with this one!)

## What Makes This Special? 🌟

- **No account needed** - Just open and start using
- **Works offline** - Built-in card database means no internet? No problem!
- **Smooth animations** - Everything feels polished and responsive
- **Type-based colors** - Each Pokémon type has its own color scheme
- **Persistent storage** - Your favorites don't disappear when you close the app
- **Resizable window** - Make it as big or small as you want (minimum size is 360x640 like a phone)

## Tech Stack 🛠️

For those interested in the technical details:
- **Flutter & Dart** - Cross-platform framework
- **Pokémon TCG API v2** - Official card database
- **cached_network_image** - Fast image loading and caching
- **shared_preferences** - Local data storage
- **Material Design 3** - Modern, beautiful UI components

## Future Ideas 💭

Some things I'm thinking about adding:
- Deck builder feature
- Card filtering by rarity or set
- Share cards with friends
- Export favorites list
- More detailed card stats and abilities

## Development Process 💻

### My Original Work & Ideas
I came up with all the core concepts and features for this app myself:
- **Original Idea**: Phone-style navigation with bottom tabs - I wanted it to feel like a real mobile app
- **Home Screen**: Designed the 4-tab navigation system (Cards, Battle, Favorites, Settings) from scratch
- **Favorites Feature**: My own idea to add a heart button on each card and save them permanently
- **Search & Filters**: Implemented the search bar and type filter chips myself to make browsing easier
- **Battle Mode**: Came up with the comparison feature to compare two cards side-by-side
- **UI Design**: All the color schemes, gradients, and card layouts are my design choices
- **Settings Screen**: Created statistics, theme toggle, and data management features on my own
- **Window Sizing**: Configured the app to open at phone dimensions (400x800) with proper resizing
- **300 Cards**: Decided to include cards from Base Set, Jungle, Fossil, and Team Rocket sets

### What I Built By Hand
Most of the code is written by me:
- All screen layouts and navigation structure
- Card list with scrolling and animations
- Favorites system with persistent storage (SharedPreferences)
- Search and filter logic for finding cards
- Battle screen for comparing cards
- Settings screen with all the options
- Theme switching between light and dark mode
- Integration with Pokémon TCG API
- Error handling and offline mode

### AI Assistance
I used AI (GitHub Copilot) to help with some technical parts:
- Writing detailed code comments to explain how everything works
- Fixing deprecation warnings and code cleanup
- Suggesting best practices for Flutter animations
- Helping debug a few layout overflow issues
- Generating the README documentation
- Adding type-based gradient backgrounds to detail screen

The AI was basically like having a coding tutor - I told it what I wanted to build, and it helped me write cleaner code and fix technical issues. All the features, design decisions, and app structure came from my own ideas and planning.

## Credits 👏

- Card data and images from [Pokémon TCG API](https://pokemontcg.io/)
- Built with Flutter by Google
- Pokémon and all respective names are trademark of Nintendo/Game Freak
- Development assistance from GitHub Copilot for code optimization and documentation

## Need Help? 🤔

If something isn't working right:
1. Make sure you're connected to the internet (for first-time loading)
2. Try the "Refresh Collection" button in Settings
3. Check that you have the latest Flutter SDK installed
4. If images aren't loading, give it a few seconds - they cache after the first load

---

**Made with ❤️ and a lot of nostalgia for those classic Pokémon cards!**

Hope you enjoy using this app as much as I enjoyed building it. Happy collecting! 🎉
