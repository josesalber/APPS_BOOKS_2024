import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/services/course_service.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/course_detail_page.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/app_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/UserPageConfig/course_card.dart'; // Import CourseCard
import 'package:http/http.dart' as http;
import 'dart:convert';

class FreeCoursesPage extends StatefulWidget {
  const FreeCoursesPage({super.key});

  @override
  _FreeCoursesPageState createState() => _FreeCoursesPageState();
}

class _FreeCoursesPageState extends State<FreeCoursesPage> {
  final CourseService _courseService = CourseService();
  List<Course> courses = [];
  List<Course> filteredCourses = [];
  String selectedCategory = "All";
  List<String> categories = ["All"];
  String searchQuery = "";
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchRandomImage();
  }

  Future<void> fetchCourses() async {
    try {
      final fetchedCourses = await _courseService.fetchCourses(300);
      setState(() {
        courses = fetchedCourses.where((course) => !course.isExpired()).toList();
        filteredCourses = courses;
        categories = ["All"];
        categories.addAll(courses.map((course) => course.category).toSet().cast<String>().toList());
        _filterCourses();
      });
    } catch (e) {
      throw Exception('Fallo en carga de cursos');
    }
  }

  Future<void> fetchRandomImage() async {
    final response = await http.get(Uri.parse('https://source.unsplash.com/random/800x600'));
    if (response.statusCode == 200) {
      setState(() {
        imageUrl = response.request!.url.toString();
      });
    }
  }

  void _filterCourses() {
    setState(() {
      filteredCourses = courses.where((course) {
        final matchesCategory = selectedCategory == "All" || course.category == selectedCategory;
        final matchesSearch = course.title.toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _filterCoursesByCategory(String category) {
    setState(() {
      selectedCategory = category;
      _filterCourses();
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri courseUrl = Uri.parse(url);
    if (await canLaunchUrl(courseUrl)) {
      await launchUrl(courseUrl);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: fetchCourses,
        child: filteredCourses.isEmpty
            ? _buildEmptyState()
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return ListView.builder(
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        return CourseCard(course: course); // Usa CourseCard
                      },
                    );
                  } else {
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        return CourseCard(course: course); // Usa CourseCard
                      },
                    );
                  }
                },
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Padding(
          padding: AppStyles.searchFieldPadding,
          child: Column(
            children: [
              const Text(
                'Cursos gratuitos 9.0',
                style: TextStyles.title,
              ),
              const SizedBox(height: 10),
              _buildSearchField(),
              const SizedBox(height: 10),
              _buildCategoryFilter(),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Buscar cursos...',
        labelStyle: TextStyles.searchField,
        filled: true,
        fillColor: AppStyles.searchFieldDecoration.color,
        border: OutlineInputBorder(
          borderRadius: AppStyles.searchFieldDecoration.borderRadius as BorderRadius,
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.search, color: Colors.white),
      ),
      onChanged: (value) {
        searchQuery = value;
        _filterCourses();
      },
    );
  }

  Container _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: AppStyles.categoryFilterDecoration,
      child: Row(
        children: [
          const Text(
            'Filtrar por:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: AppStyles.dropdownDecoration,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _filterCoursesByCategory(value!);
                  },
                  dropdownColor: const Color(0xFF6c61af),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              height: 150,
            ),
          const SizedBox(height: 20),
          const Text(
            '¡El curso que buscas no está de oferta!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Regresa pronto para ver las nuevas ofertas.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}