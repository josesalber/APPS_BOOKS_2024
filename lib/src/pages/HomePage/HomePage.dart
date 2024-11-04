// lib/src/pages/HomePage/HomePage.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/FreeCoursesPage.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/libros.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/Principal.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/CustomAppBar.dart'; 


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: const CustomAppBar(), 
        body: const TabBarView(
          children: [
            Principal(), // el home xd
            LibrosPage(), // Contenido de la pestaña "Libros"
            FreeCoursesPage(), // Contenido de la pestaña "Cursos"
          ],
        ),
        bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), 
          child: Container(
            color: const Color(0xFF2f2c44), // Color del navbar
            child: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.home, size: 24), 
                ),
                Tab(
                  icon: Icon(Icons.book, size: 24), 
                ),
                Tab(
                  icon: Icon(Icons.new_releases, size: 24), 
                )
              ],
              labelColor: Colors.white, 
              unselectedLabelColor: Colors.white54, 
              indicator: BoxDecoration(
                color: const Color(0xFF1c1a29), 
                borderRadius: BorderRadius.circular(10), 
                border: Border.all(
                  color: const Color(0xFF1c1a29), 
                  width: 2.0, 
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              indicatorWeight: 4.0,
            ),
          ),
        ),
      ),
    );
  }
}