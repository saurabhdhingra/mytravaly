import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mytravaly/data/provider/auth.dart';
import 'package:mytravaly/data/service/authentication.dart';
import 'package:mytravaly/presentation/auth/sign_in.dart';
import 'package:mytravaly/presentation/home/home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const FlutterSecureStorage storage = FlutterSecureStorage();
  final AuthService authService = AuthService(storage);

  runApp(
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
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: Consumer<AuthNotifier>(
        builder: (context, auth, child) {
          if (auth.isLoading) {
            return const LoadingScreen();
          }
          if (auth.isAuthenticated) {
            return const HomePage();
          }
          return const SignInPage();
        },
      ),
    );
  }
}