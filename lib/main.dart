import 'package:flutter/material.dart';
import 'package:recipe_app/screens/history_screen.dart';
import 'package:recipe_app/screens/signup_page.dart';
import 'screens/home_screen.dart';
import 'screens/ingredients_screen.dart';
import 'screens/recommended_recipes_screen.dart';
import 'screens/snap_food_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_page.dart';
import 'screens/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Pantry - AI Recipe App',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFF7B5EF0, {
          50: Color(0xFFF3F0FF),
          100: Color(0xFFE4DBFF),
          200: Color(0xFFCFBEFF),
          300: Color(0xFFB8A1FF),
          400: Color(0xFFA489FF),
          500: Color(0xFF7B5EF0),
          600: Color(0xFF6B4FE8),
          700: Color(0xFF5A42E0),
          800: Color(0xFF4A36D8),
          900: Color(0xFF3425CC),
        }),
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(home: HomeScreen()),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/home': (_) => HomeScreen(),
        '/ingredients': (_) => IngredientsScreen(),
        '/recipe-book': (_) => const RecipeBookScreen(),
        '/snap-food': (_) => SnapFoodScreen(),
        '/profile': (_) => ProfileScreen(),
        '/history': (_) => HistoryPage(),
      },
    );
  }
}