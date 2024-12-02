import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/app_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/course_detail_page.dart'; // Importa CourseDetailPage

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 400,
          ),
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