import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FreeCoursesPage extends StatefulWidget {
  const FreeCoursesPage({super.key});

  @override
  _FreeCoursesPageState createState() => _FreeCoursesPageState();
}

class _FreeCoursesPageState extends State<FreeCoursesPage> {
  List<dynamic> courses = [];
  List<dynamic> filteredCourses = [];
  String selectedCategory = "All";
  List<String> categories = ["All"];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final response = await http.get(
      Uri.parse('https://coupons.thanh0x.com/api/v1/coupons?numberPerPage=20'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        courses = data['courses'];
        filteredCourses = courses;

        categories.addAll(courses
            .map((course) => course['category'] ?? 'Unknown')
            .toSet()
            .cast<String>()
            .toList());
      });
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri courseUrl = Uri.parse(url);
    if (await canLaunchUrl(courseUrl)) {
      await launchUrl(courseUrl);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _filterCourses() {
    setState(() {
      filteredCourses = courses.where((course) {
        final matchesCategory = selectedCategory == "All" ||
            (course['category'] != null && course['category'] == selectedCategory);
        final matchesSearch = course['title'].toLowerCase().contains(searchQuery.toLowerCase());
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

  String getExpiryTime(DateTime expires) {
    final now = DateTime.now();
    final difference = expires.difference(now);

    if (difference.inDays > 0) {
      return "Expira en: ${difference.inDays} días";
    } else if (difference.inHours > 0) {
      return "Expira en: ${difference.inHours} horas";
    } else if (difference.inMinutes > 0) {
      return "Expira en: ${difference.inMinutes} minutos";
    } else {
      return "Expirado";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Column(
              children: [
                Text(
                  'Cursos gratuitos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar cursos...',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterCourses();
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF302f3c),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Filtrar por:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF6c61af),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                _filterCoursesByCategory(value!);
                              },
                              dropdownColor: Color(0xFF6c61af),
                            ),
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
      ),
      body: filteredCourses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                final expires = DateTime.parse(course['expiredDate']);
                final daysLeft = getExpiryTime(expires);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15.0),
                          ),
                          child: Image.network(
                            course['previewImage'] ?? '',
                            height: 120, // Reduce la altura de la imagen
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Instructor: ${course['author']}",
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                              Text(
                                "Categoría: ${course['category'] ?? 'Desconocido'}",
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              Text(
                                "Calificación: ${course['rating']?.toStringAsFixed(1) ?? 'N/A'}",
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              Text(
                                daysLeft,
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(height: 3),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6c61af),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _launchUrl(course['couponUrl']);
                                  },
                                  child: const Text('Ver curso'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}