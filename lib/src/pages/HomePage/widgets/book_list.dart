import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/detalle_libro.dart';
import '../widgets/UserPageConfig/favorites.dart';

class BookList extends StatelessWidget {
  final List<dynamic> libros;

  const BookList({super.key, required this.libros});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: libros.length,
      itemBuilder: (context, index) {
        final libro = libros[index];
        final title = libro['title'];
        final author = libro['author'];
        final imageUrl = libro['imgUrl'];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleLibroPage(
                  title: title,
                  author: author,
                  imageUrl: imageUrl,
                  size: libro['size'],
                  genre: libro['genre'],
                  year: libro['year'],
                  format: libro['format'],
                  md5: libro['md5'],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 150,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 150);
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.title,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Autor: $author',
                        style: TextStyles.bodyText,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  onPressed: () {
                    addToFavorites(libro);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}