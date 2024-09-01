import 'package:flutter/material.dart';
import 'FreeCoursesPage.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Udemy Free Courses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FreeCoursesPage(),
    );
  }
}
