import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/FreeCoursesPage.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/services/course_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/course_detail_page.dart'; // Importa la página de detalle del curso

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  List<Course> latestCourses = [];
  List<String> userPreferences = [];

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
  }

  Future<void> fetchLatestCourses() async {
    try {
      final courseService = CourseService();
      final allCourses = await courseService.fetchCourses(300); // Fetch a large number of courses

      // Filter courses based on user preferences
      final filteredCourses = <Course>[];
      for (final preference in userPreferences) {
        final coursesForPreference = allCourses.where((course) => course.category == preference).take(2).toList();
        filteredCourses.addAll(coursesForPreference);
        if (filteredCourses.length >= 6) break; // Stop if we have enough courses
      }

      setState(() {
        latestCourses = filteredCourses.take(6).toList(); // Ensure we only have a maximum of 6 courses
      });
    } catch (e) {
      print('Failed to load courses: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchLatestCourses();
        }, // Recargar la API al iniciar la aplicación
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('user_data').doc('preferences').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar preferencias'));
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              final preferencesData = snapshot.data!.data() as Map<String, dynamic>;
              userPreferences = List<String>.from(preferencesData['coursePreferences'] ?? []);
              fetchLatestCourses();
            }

            return ListView(
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailPage(course: course),
                            ),
                          );
                        },
                        child: Container(
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
                                    course.previewImage,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 16.0,
                                  left: 16.0,
                                  right: 16.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: course.getCategoryColor(),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          course.category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        course.title,
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
                                    ],
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
            );
          },
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