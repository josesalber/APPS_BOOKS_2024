import 'package:flutter/material.dart';

class LibrosPage extends StatelessWidget {
  const LibrosPage({super.key});

  final List<Map<String, String>> books = const [
    {
      'title': 'Flutter para Principiantes',
      'course': 'Desarrollo Móvil',
      'year': '2024',
      'author': 'Juan Pérez',
    },
    {
      'title': 'Dart Avanzado',
      'course': 'Programación',
      'year': '2023',
      'author': 'Ana Gómez',
    },
    {
      'title': 'Diseño de Interfaces',
      'course': 'UI/UX',
      'year': '2022',
      'author': 'Carlos López',
    },
    // Agrega más libros aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: books.map((book) => BookCard(book: book)).toList(),
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Map<String, String> book;

  const BookCard({required this.book, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 154, 140, 173),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 177, 173, 184).withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del libro

            // Nombre del libro
            Text(
              book['title']!,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            // Curso
            Text(
              book['course']!,
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            // Año
            Text(
              book['year']!,
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 4.0),
            // Autor
            Text(
              book['author']!,
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
