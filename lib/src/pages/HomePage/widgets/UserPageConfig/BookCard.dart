import 'package:flutter/material.dart';
import '../text_styles.dart';
import '../detalle_libro.dart';
import '../UserPageConfig/favorites.dart';

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final Function(String) onRemove;

  const BookCard({
    super.key,
    required this.book,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleLibroPage(
              title: book['title'] ?? '',
              author: book['author'] ?? '',
              imageUrl: book['imgUrl'] ?? '',
              size: book['size'] ?? '',
              genre: book['genre'] ?? '',
              year: book['year'] ?? '',
              format: book['format'] ?? '',
              md5: book['md5'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
            book['imgUrl'] != null && book['imgUrl'].isNotEmpty
                ? Image.network(
                    book['imgUrl'],
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
                    book['title'] ?? '',
                    style: TextStyles.title,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Autor: ${book['author'] ?? ''}',
                    style: TextStyles.bodyText,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () {
                addToFavorites(book);
              },
            ),
          ],
        ),
      ),
    );
  }
}