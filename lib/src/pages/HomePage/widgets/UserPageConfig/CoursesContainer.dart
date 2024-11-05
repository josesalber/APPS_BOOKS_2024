import 'package:flutter/material.dart';

class CoursesContainer extends StatelessWidget {
  const CoursesContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400, // Aumentar la altura de los cuadros
      child: Container(
        key: const ValueKey('courses'),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Cursos guardados',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Aquí puedes agregar más contenido relacionado con los cursos guardados
          ],
        ),
      ),
    );
  }
}