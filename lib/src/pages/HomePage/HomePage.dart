import 'package:flutter/material.dart';
import 'tabs/cursos.dart';
import 'tabs/libros.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APPrendiendo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('APPrendiendo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Libros'),
              Tab(icon: Icon(Icons.star), text: 'Favoritos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LibrosPage(), // Contenido de la pestaña "Libros"
            FavoritosPage(), // Contenido de la pestaña "Favoritos"
          ],
        ),
      ),
    );
  }
}
