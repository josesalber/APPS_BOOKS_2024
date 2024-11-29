import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/FreeCoursesPage.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/libros.dart';
import 'package:flutter_application_1/services/course_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/course_detail_page.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/detalle_libro.dart';
import 'package:flutter_application_1/services/annas_archive_api.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/DetalleNoticiaPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  List<Course> latestCourses = [];
  List<Map<String, dynamic>> latestBooks = [];
  List<String> userPreferences = [];
  List<Map<String, dynamic>> news = [];
  Timer? _timer;
  bool _isLoading = true;

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
    _loadCachedContent();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchLatestContent();
    });
    _fetchNews();
  }

  Future<void> _loadCachedContent() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCourses = prefs.getString('latestCourses');
    final cachedBooks = prefs.getString('latestBooks');

    if (cachedCourses != null && cachedBooks != null) {
      setState(() {
        latestCourses = (json.decode(cachedCourses) as List).map((data) => Course.fromJson(data)).toList();
        latestBooks = (json.decode(cachedBooks) as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      fetchLatestContent();
    }
  }

  Future<void> fetchLatestContent() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final courseService = CourseService();
      final allCourses = await courseService.fetchCourses(300);

      final filteredCourses = <Course>[];
      if (userPreferences.isNotEmpty) {
        for (final preference in userPreferences) {
          final coursesForPreference = allCourses.where((course) => course.category == preference).take(2).toList();
          filteredCourses.addAll(coursesForPreference);
          if (filteredCourses.length >= 6) break;
        }
      } else {
        allCourses.shuffle();
        filteredCourses.addAll(allCourses.take(6));
      }

      final books = await AnnasArchiveApi.searchBooks('');
      books.shuffle();
      final filteredBooks = books.take(6).toList();

      setState(() {
        latestCourses = filteredCourses.take(6).toList();
        latestBooks = filteredBooks.cast<Map<String, dynamic>>();
        _isLoading = false;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('latestCourses', json.encode(latestCourses));
      prefs.setString('latestBooks', json.encode(latestBooks));
    } catch (e) {
      print('Failed to load content: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNews() async {
    try {
      final newsSnapshot = await FirebaseFirestore.instance.collection('Noticias').orderBy('timestamp', descending: true).get();
      setState(() {
        news = newsSnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchLatestContent();
          await _fetchNews();
        },
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
            }

            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
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
                      const SizedBox(height: 8.0),
                      news.isEmpty
                          ? const FadeInText(
                              text: '¡Muy pronto habrán noticias!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : CarouselSlider.builder(
                              itemCount: news.length,
                              itemBuilder: (context, index, realIndex) {
                                final item = news[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalleNoticiaPage(
                                          banner: item['banner'],
                                          title: item['title'],
                                          info: item['info'],
                                          link: item['link'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
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
                                              item['banner'],
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
                                                    color: Colors.black54,
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  child: Text(
                                                    item['title'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
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
                              options: CarouselOptions(
                                height: 200.0,
                                enlargeCenterPage: true,
                                autoPlay: true,
                                aspectRatio: 16 / 9,
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enableInfiniteScroll: true,
                                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                viewportFraction: 0.8,
                              ),
                            ),
                      const SizedBox(height: 16.0),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(color: Colors.white54),
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
                      const SizedBox(height: 16.0),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(color: Colors.white54),
                      ),
                      SizedBox(
                        height: 200.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: latestBooks.length,
                          itemBuilder: (context, index) {
                            final book = latestBooks[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalleLibroPage(
                                      title: book['title'],
                                      author: book['author'],
                                      imageUrl: book['imgUrl'],
                                      size: book['size'],
                                      genre: book['genre'],
                                      year: book['year'],
                                      format: book['format'],
                                      md5: book['md5'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 120.0,
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        book['imgUrl'],
                                        height: 150,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      book['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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

  @override
  bool get wantKeepAlive => true;
}

class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FadeInText({required this.text, required this.style, Key? key}) : super(key: key);

  @override
  _FadeInTextState createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); 
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Center(
        child: Text(
          widget.text,
          style: widget.style,
        ),
      ),
    );
  }
}