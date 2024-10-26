import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/src/pages/HomePage/tabs/Libros.dart'; 
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart'; 

class FreeCoursesPage extends StatefulWidget {
  const FreeCoursesPage({super.key});

  @override
  _FreeCoursesPageState createState() => _FreeCoursesPageState();
}

class _FreeCoursesPageState extends State<FreeCoursesPage> {
  List<dynamic> courses = [];
  List<dynamic> filteredCourses = [];
  String selectedCategory = "All"; // Categoría seleccionada
  List<String> categories = ["All"]; // Lista de categorías
  String searchQuery = ""; // Query de búsqueda

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
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
        courses = data['results'];
        filteredCourses = courses;

        // Asegúrate de que category no sea nulo
        categories.addAll(courses
            .map((course) {
              if (course['category'] != null &&
                  course['category']['title'] != null) {
                return course['category']['title']
                    as String; // Asegúrate de que sea un String
              }
              return 'Unknown'; // Manejar caso donde no hay categoría
            })
            .toSet()
            .cast<String>()
            .toList()); // Convierte a Iterable<String>
      });
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://www.udemy.com$url'; // Agrega el dominio si es necesario
    }

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
            (course['category'] != null &&
                course['category']['title'] == selectedCategory);
        final matchesSearch =
            course['title'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _filterCoursesByCategory(String category) {
    setState(() {
      selectedCategory = category;
      _filterCourses(); // Filtrar por categoría
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterCoursesByCategory(
                              value!); // Filtrar por categoría
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration:  InputDecoration(
                    labelText: 'Buscar cursos...',
                    labelStyle: TextStyles.searchField,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterCourses(); // Filtrar por búsqueda
                  },
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
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              course['image_240x135'] ?? '',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            course['title'],
                            style: TextStyles.Secondtitle.copyWith(
                            color: Colors.black, //
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Instructor: ${course['visible_instructors'][0]['title']}",
                            style: TextStyles.bodyText,
                
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Category: ${course['category']?['title'] ?? 'Unknown'}",
                            style: TextStyles.subtitle,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Subcategory: ${course['subcategory']?['title'] ?? 'N/A'}",
                            style: TextStyles.subtitle,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _launchUrl(course[
                                  'url']); // Llama a la función para abrir la URL del curso
                            },
                            child: const Text('Ver curso'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}