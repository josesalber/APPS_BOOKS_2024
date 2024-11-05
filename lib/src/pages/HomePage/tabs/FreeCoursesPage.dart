import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/services/course_service.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/course_detail_page.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/app_styles.dart';

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

  @override
  void initState() {
    super.initState();
    fetchCourses();
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
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  return _buildCourseCard(course);
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

  Widget _buildCourseCard(Course course) {
    final daysLeft = course.getExpiryTime();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(course: course),
          ),
        );
      },
      child: Padding(
        padding: AppStyles.containerMargin,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseImage(course),
              Padding(
                padding: AppStyles.courseCardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseTitle(course),
                    const SizedBox(height: 5),
                    _buildCourseInfoRow(course),
                    const SizedBox(height: 5),
                    _buildCourseAuthor(course),
                    const SizedBox(height: 5),
                    _buildCourseCategory(course),
                    if (daysLeft.isNotEmpty)
                      Text(
                        daysLeft,
                        style: const TextStyle(fontSize: 14, color: Colors.redAccent),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect _buildCourseImage(Course course) {
    return ClipRRect(
      borderRadius: AppStyles.courseDetailImageDecoration.borderRadius ?? BorderRadius.zero,
      child: Image.network(
        course.previewImage,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Text _buildCourseTitle(Course course) {
    return Text(
      course.title,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Row _buildCourseInfoRow(Course course) {
    return Row(
      children: [
        Text(
          "⭐ ${course.rating.toStringAsFixed(1)}",
          style: const TextStyle(fontSize: 14, color: Colors.orange),
        ),
        const SizedBox(width: 10),
        Text(
          "👤 ${course.students}",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(width: 10),
        Text(
          "⏰ ${course.contentLength} mins",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Text _buildCourseAuthor(Course course) {
    return Text(
      "Autor: ${course.author}",
      style: const TextStyle(fontSize: 14, color: Colors.black54),
    );
  }

  Container _buildCourseCategory(Course course) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: AppStyles.courseCategoryDecoration.copyWith(
        color: course.getCategoryColor(),
      ),
      child: Text(
        course.category,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}