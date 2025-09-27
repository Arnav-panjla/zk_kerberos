import 'package:flutter/material.dart'; // ADD THIS IMPORT
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart';
import 'screens/services_page.dart';
import 'screens/authentication_page.dart';
import 'screens/settings_page.dart';
import 'models/settings_model.dart';

// ... the rest of your main.dart file remains exactly the same
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00BFA5);
    const darkBackgroundColor = Color(0xFF121212);
    const darkCardColor = Color(0xFF1E1E1E);
    const lightBackgroundColor = Color(0xFFF5F5F7);
    const lightCardColor = Colors.white;

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      primaryColor: accentColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
        background: darkBackgroundColor,
        surface: darkCardColor,
        onPrimary: Colors.black,
        onBackground: Color(0xFFE0E0E0),
        onSurface: Color(0xFFE0E0E0),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFE0E0E0),
        displayColor: const Color(0xFFE0E0E0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      useMaterial3: true,
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackgroundColor,
      primaryColor: accentColor,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        background: lightBackgroundColor,
        surface: lightCardColor,
        onPrimary: Colors.white,
        onBackground: const Color(0xFF1D1D1F),
        onSurface: const Color(0xFF1D1D1F),
        error: Colors.red.shade700,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: const Color(0xFF1D1D1F),
        displayColor: const Color(0xFF1D1D1F),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D1D1F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      useMaterial3: true,
    );
    
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        final currentTheme = settings.themeMode == ThemeMode.light 
            ? lightTheme 
            : darkTheme;

        return AnimatedTheme(
          data: settings.themeMode == ThemeMode.system
              ? (MediaQuery.of(context).platformBrightness == Brightness.dark ? darkTheme : lightTheme)
              : currentTheme,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: MaterialApp(
            title: 'zk-Kerberos App',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginPage(),
              '/services': (context) => const ServicesPage(),
              '/settings': (context) => const SettingsPage(),
              '/authenticate': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                return AuthenticatePage(
                  userId: args['userId'] as String,
                  password: args['password'] as String,
                  service: args['service'] as Map<String, String>,
                );
              },
            },
          ),
        );
      },
    );
  }
}