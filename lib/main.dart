import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/HomePage/HomePage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APPRENDE+',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1C1C2D), // Fondo de pantalla muy oscuro
        primaryColor: const Color(0xFF1C1C2D), // Color primario
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C2D), // Fondo de AppBar muy oscuro
        ),

      ),
      home: const HomePage(),
    );
  }
}