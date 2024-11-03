import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';

class CourseInfoRow extends StatelessWidget {
  final Course course;

  const CourseInfoRow({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoContainer(
          color: Colors.blue,
          icon: Icons.person,
          text: "Tutor: ${course.author}",
        ),
        _buildInfoContainer(
          color: Colors.orange,
          icon: Icons.group,
          text: "${course.students} estudiantes",
        ),
      ],
    );
  }

  Widget _buildInfoContainer({required Color color, IconData? icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyles.infoText,
          ),
        ],
      ),
    );
  }
}