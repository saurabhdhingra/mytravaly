import 'package:flutter/material.dart';
import 'package:mytravaly/data/provider/auth.dart';
import 'package:mytravaly/data/service/authentication.dart';
import 'package:mytravaly/presentation/auth/sign_in.dart';
import 'package:mytravaly/presentation/home/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure Flutter engine is initialized before using plugins like SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get the shared preferences instance
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AuthService authService = AuthService(prefs);

  runApp(
    // Global Provider wrapping the entire app
    ChangeNotifierProvider(
      create: (context) => AuthNotifier(authService),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Booking Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      // Use Consumer to decide which page to show based on Auth state
      home: Consumer<AuthNotifier>(
        builder: (context, auth, child) {
          if (auth.isLoading) {
            return const LoadingScreen();
          }
          // If token exists, go to the Home Page (Page 2)
          if (auth.isAuthenticated) {
            return const HomePage();
          }
          // Otherwise, show the Sign-In Page (Page 1)
          return const SignInPage();
        },
      ),
    );
  }
}