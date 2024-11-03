// lib/services/course_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/course.dart';

class CourseService {
  final String baseUrl = 'https://coupons.thanh0x.com/api/v1/coupons';

  Future<List<Course>> fetchCourses(int numberPerPage) async {
    final response = await http.get(
      Uri.parse('$baseUrl?numberPerPage=$numberPerPage'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['courses'] as List)
          .map((courseJson) => Course.fromJson(courseJson))
          .toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }
}