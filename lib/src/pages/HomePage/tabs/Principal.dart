import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/FreeCoursesPage.dart'; 
import 'package:flutter_application_1/src/pages/HomePage/tabs/Libros.dart'; 
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart'; 

class Principal extends StatefulWidget {
  const Principal({Key? key}) : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  List<dynamic> latestCourses = [];
  List<dynamic> latestBooks = [];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
    fetchLatestCourses();
    fetchLatestBooks();
  }

  Future<void> fetchLatestCourses() async {
    final response = await http.get(
      Uri.parse('https://www.udemy.com/api-2.0/courses/?price=price-free'),
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Authorization':
            'Basic bXNPbzROeWp1SWt1Y01zenFpU3gxaWhTYXJlWlNvQ2ptcmZucVFiWTpWSkpwdERubkpnZlo5VUliSURRUnVIUExkY0gyd0g5RDNMYWRNY0l1d0tJdWQzZVo3S2IxYXhsbzNkV1BNVWtwUGRXZVJRSmRsRlB4Y0d0R1FOMXlyNWZqV0pqUWRFOUc3SmVKMzhqb2cwa0Q1YWRqeWQ4NHNnMVN2RkptRlBEbg==',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        latestCourses = data['results'].take(5).toList(); // Obtener los últimos 5 cursos
      });
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> fetchLatestBooks() async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/books/v1/volumes?q=flutter'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        latestBooks = data['items'].take(5).toList(); 
      });
    } else {
      throw Exception('Error al cargar libros');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchLatestCourses();
          await fetchLatestBooks();
        }, // Recargar la API al iniciar la aplicación
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Anuncios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 200.0,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 5,
                itemBuilder: (context, index) {
                  bool active = index == _currentPage;
                  return _buildBanner(active, index);
                },
              ),
            ),
            const SizedBox(height: 8.0), // Espacio entre banners y Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF4b4287) : Colors.grey,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16.0), // Espacio entre secciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimos cursos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FreeCoursesPage()),
                      );
                    },
                    child: const Text(
                      'Ver todo',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: latestCourses.length,
                itemBuilder: (context, index) {
                  final course = latestCourses[index];
                  return Container(
                    width: 300.0,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      color: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              course['image_240x135'] ?? '',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 16.0,
                            left: 16.0,
                            right: 16.0,
                            child: Text(
                              course['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0), // Espacio entre secciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimos libros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LibrosPage()),
                      );
                    },
                    child: const Text(
                      'Ver todo',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: latestBooks.length,
                itemBuilder: (context, index) {
                  final book = latestBooks[index];
                  final volumeInfo = book['volumeInfo'];
                  final title = volumeInfo['title'];
                  final imageUrl = volumeInfo['imageLinks']?['thumbnail'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleLibroPage(
                            imageUrl: imageUrl,
                            titulo: title,
                            autor: volumeInfo['authors']?.join(', ') ?? 'Desconocido',
                            materia: 'Programación',
                            anio: volumeInfo['publishedDate'] ?? 'Desconocido',
                            previewLink: volumeInfo['previewLink'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 150.0,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 16.0,
                              left: 16.0,
                              right: 16.0,
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0), // Hacer el borde más grueso
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(bool active, int index) {
    final double blur = active ? 10 : 0;
    final double offset = active ? 10 : 0;
    final double top = active ? 5 : 20;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 20, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: const LinearGradient(
          colors: [Color(0xFFD1C4E9), Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: blur,
            offset: Offset(offset, offset),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Banner $index',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}