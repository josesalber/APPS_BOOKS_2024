import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/FreeCoursesPage.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/libros.dart';

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
        primarySwatch: Colors.red,
        fontFamily: 'SFPRODISPLAY',
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
        ),
        body: const TabBarView(
          children: [
            LibrosPage(), // Contenido de la pestaña "Libros"
            FreeCoursesPage(), // Contenido de la pestaña "Cursos"
          ],
        ),
        bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Altura del TabBar
          child: Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.book, size: 18),
                ), // Icono más pequeño
                Tab(
                  icon: Icon(Icons.star, size: 18),
                ), // Icono más pequeño
              ],
              labelColor: Colors.white, // Color del texto seleccionado
              unselectedLabelColor:
                  Colors.white54, // Color del texto no seleccionado
              indicator: BoxDecoration(
                color: const Color.fromARGB(
                    255, 42, 149, 236), // Color del indicador
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
              ),
            ),
          ),
        ),
      ),
    );
  }
}
