import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FreeCoursesPage extends StatefulWidget {
  const FreeCoursesPage({super.key});

  @override
  _FreeCoursesPageState createState() => _FreeCoursesPageState();
}

class _FreeCoursesPageState extends State<FreeCoursesPage> {
  List courses = [];

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
      });
    } else {
      throw Exception('Failed to load courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos Gratuitos en Udemy'),
      ),
      body: courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  leading: Image.network(
                    course['image_125_H'] ?? '',
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(course['title']),
                  subtitle: Text(course['visible_instructors'][0]['title']),
                  onTap: () {
                    // Aquí puedes redirigir a una página de detalles del curso o a la URL del curso.
                  },
                );
              },
            ),
    );
  }
}
