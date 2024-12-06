import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/pages/HomePage/HomePage.dart';
import 'src/pages/HomePage/Login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ApprendeApp());
}

class ApprendeApp extends StatelessWidget {
  const ApprendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APPRENDE+',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1C1C2E),
        scaffoldBackgroundColor: const Color(0xFF1C1C2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C2E),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false, 
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}