import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // ========================================================================
  // LIGHT THEME - Used during daytime/bright environments
  // Colors optimized for readability on light backgrounds
  // ========================================================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Performance optimizations
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashFactory: NoSplash.splashFactory, // Disable ripple animations
    colorScheme: const ColorScheme.light(
      // PRIMARY COLOR: Orange (#FF8C00) - Main brand color for Light Mode
      // Used in: App bars, elevated buttons, progress indicators, active states
      // Locations: Worker/User home headers, report list app bar, login buttons,
      // navigation highlights, switch active state, floating action buttons
      primary: Color(0xFFFF8C00), // Orange
      
      // SECONDARY COLOR: Blue (#2196F3) - Accent color for Light Mode  
      // Used in: Secondary buttons, chips, icons, accent elements
      // Locations: Filter chips, secondary actions, info indicators,
      // some status badges, complementary UI elements
      secondary: Color(0xFF2196F3), // Blue
      
      // SURFACE COLOR: Very Light Gray (#F8F9FA) - Card and surface backgrounds
      // Used in: Cards, bottom sheets, dialogs, elevated surfaces
      // Locations: Report cards, settings cards, profile cards, filter chip container,
      // drawer background, modal backgrounds, elevated containers
      surface: Color(0xFFF8F9FA),
      
      // BACKGROUND COLOR: Very Light Gray (#F8F9FA) - Main screen background
      // Used in: Scaffold background, main screen backgrounds
      // Locations: All screen backgrounds (home, reports, settings, etc.),
      // main container backgrounds, list view backgrounds
      background: Color(0xFFF8F9FA),
      
      // ON-PRIMARY COLOR: White - Text/icons displayed on primary color
      // Used in: Text and icons on orange backgrounds
      // Locations: App bar titles, button text on primary buttons,
      // search field text, header text, icons on primary backgrounds
      onPrimary: Colors.white,
      
      // ON-SECONDARY COLOR: White - Text/icons displayed on secondary color
      // Used in: Text and icons on blue backgrounds
      // Locations: Text on secondary buttons, icons on blue chips,
      // content on secondary colored surfaces
      onSecondary: Colors.white,
      
      // ON-SURFACE COLOR: Very Dark Gray (#1A1A1A) - Text on surface/background
      // Used in: Primary text content, titles, labels
      // Locations: Report titles, user names, descriptions, form labels,
      // navigation labels, card content text, settings options
      onSurface: Color(0xFF1A1A1A),
    ),
    
    // SCAFFOLD BACKGROUND: Very Light Gray (#F8F9FA) - Main app background
    // Used in: All screen backgrounds as fallback
    // Locations: Every screen's base background color
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    
    // APP BAR THEME: Orange header bars with white text
    // Used in: All app bars throughout the app
    // Locations: Home screens, report lists, settings, profile screens
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0, // Flat design - no shadow
      backgroundColor: Color(0xFFFF8C00), // Orange background
      foregroundColor: Colors.white, // White text and icons
    ),
    
    // CARD THEME: White cards with subtle shadows
    // Used in: All card components throughout the app
    // Locations: Report cards, statistics cards, profile cards, settings cards,
    // dashboard cards, information containers
    cardTheme: CardTheme(
      elevation: 2, // Subtle shadow
      color: Colors.white, // Pure white card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
    ),
    
    // ELEVATED BUTTON THEME: Orange buttons with white text
    // Used in: Primary action buttons throughout the app
    // Locations: Login/signup buttons, submit buttons, primary actions,
    // create report button, update status buttons, save buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Flat design
        backgroundColor: const Color(0xFFFF8C00), // Orange background
        foregroundColor: Colors.white, // White text
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // INPUT DECORATION THEME: Light gray input fields
    // Used in: All text input fields throughout the app
    // Locations: Login forms, signup forms, search fields, description inputs,
    // comment fields, profile edit forms, filter inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100], // Very light gray background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // No border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF8C00)), // Orange focus border
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red), // Red error border
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    
    // BOTTOM NAVIGATION THEME: White bottom nav with orange selection
    // Used in: Bottom navigation bars for both user types
    // Locations: Normal user bottom nav, worker bottom nav
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, // White background
      selectedItemColor: Color(0xFFFF8C00), // Orange for selected items
      unselectedItemColor: Colors.grey, // Gray for unselected items
    ),
  );

  // ========================================================================
  // DARK THEME - Used during nighttime/low-light environments
  // Colors optimized for reduced eye strain in dark environments
  // ========================================================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // Performance optimizations
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashFactory: NoSplash.splashFactory, // Disable ripple animations
    colorScheme: const ColorScheme.dark(
      // PRIMARY COLOR: Indigo (#6366F1) - Main brand color for Dark Mode
      // Used in: App bars, elevated buttons, progress indicators, active states
      // Locations: Worker/User home headers, report list app bar, login buttons,
      // navigation highlights, switch active state, floating action buttons
      primary: Color(0xFF6366F1), // Indigo
      
      // SECONDARY COLOR: Purple (#8B5CF6) - Accent color for Dark Mode
      // Used in: Secondary buttons, chips, icons, accent elements  
      // Locations: Filter chips, secondary actions, info indicators,
      // some status badges, complementary UI elements
      secondary: Color(0xFF8B5CF6), // Purple
      
      // SURFACE COLOR: Dark Gray (#1E1E1E) - Card and surface backgrounds
      // Used in: Cards, bottom sheets, dialogs, elevated surfaces
      // Locations: Report cards, settings cards, profile cards, filter chip container,
      // drawer background, modal backgrounds, elevated containers
      surface: Color(0xFF1E1E1E),
      
      // BACKGROUND COLOR: Very Dark Gray (#121212) - Main screen background
      // Used in: Scaffold background, main screen backgrounds
      // Locations: All screen backgrounds (home, reports, settings, etc.),
      // main container backgrounds, list view backgrounds
      background: Color(0xFF121212),
      
      // ON-PRIMARY COLOR: White - Text/icons displayed on primary color
      // Used in: Text and icons on indigo backgrounds
      // Locations: App bar titles, button text on primary buttons,
      // search field text, header text, icons on primary backgrounds
      onPrimary: Colors.white,
      
      // ON-SECONDARY COLOR: White - Text/icons displayed on secondary color
      // Used in: Text and icons on purple backgrounds
      // Locations: Text on secondary buttons, icons on purple chips,
      // content on secondary colored surfaces
      onSecondary: Colors.white,
      
      // ON-SURFACE COLOR: Light Gray (#E5E7EB) - Text on surface/background
      // Used in: Primary text content, titles, labels
      // Locations: Report titles, user names, descriptions, form labels,
      // navigation labels, card content text, settings options
      onSurface: Color(0xFFE5E7EB),
    ),
    
    // SCAFFOLD BACKGROUND: Very Dark Gray (#121212) - Main app background
    // Used in: All screen backgrounds as fallback
    // Locations: Every screen's base background color
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    // APP BAR THEME: Indigo header bars with white text
    // Used in: All app bars throughout the app
    // Locations: Home screens, report lists, settings, profile screens
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0, // Flat design - no shadow
      backgroundColor: Color(0xFF6366F1), // Indigo background
      foregroundColor: Colors.white, // White text and icons
    ),
    
    // CARD THEME: Dark gray cards with subtle elevation
    // Used in: All card components throughout the app
    // Locations: Report cards, statistics cards, profile cards, settings cards,
    // dashboard cards, information containers
    cardTheme: CardTheme(
      elevation: 2, // Subtle shadow
      color: const Color(0xFF1E1E1E), // Dark gray card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
    ),
    
    // ELEVATED BUTTON THEME: Indigo buttons with white text
    // Used in: Primary action buttons throughout the app
    // Locations: Login/signup buttons, submit buttons, primary actions,
    // create report button, update status buttons, save buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Flat design
        backgroundColor: const Color(0xFF6366F1), // Indigo background
        foregroundColor: Colors.white, // White text
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // INPUT DECORATION THEME: Dark gray input fields
    // Used in: All text input fields throughout the app
    // Locations: Login forms, signup forms, search fields, description inputs,
    // comment fields, profile edit forms, filter inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A), // Dark gray background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // No border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6366F1)), // Indigo focus border
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red), // Red error border
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    
    // BOTTOM NAVIGATION THEME: Dark bottom nav with indigo selection
    // Used in: Bottom navigation bars for both user types
    // Locations: Normal user bottom nav, worker bottom nav
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E), // Dark gray background
      selectedItemColor: Color(0xFF6366F1), // Indigo for selected items
      unselectedItemColor: Colors.grey, // Gray for unselected items
    ),
  );
}

// ========================================================================
// THEME NOTIFIER - Manages theme switching and persistence
// Handles switching between light and dark modes with SharedPreferences
// ========================================================================
class AppThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Returns current theme based on _isDarkMode flag
  // Used by: MaterialApp in main.dart through Consumer<AppThemeNotifier>
  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  AppThemeNotifier() {
    _loadTheme();
  }

  // Loads saved theme preference from SharedPreferences on app startup
  // Default: Light mode if no preference saved
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Toggles between light and dark mode
  // Used by: Potential toggle buttons (not currently implemented in UI)
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Sets specific theme mode (true = dark, false = light)
  // Used by: Settings screen switch widget for theme selection
  // Location: lib/shared/settings_screen.dart line 216
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
} 