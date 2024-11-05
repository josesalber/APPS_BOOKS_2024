import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/services/annas_archive_api.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleLibroPage extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final String size;
  final String genre;
  final String year;
  final String format;
  final String md5;

  const DetalleLibroPage({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.size,
    required this.genre,
    required this.year,
    required this.format,
    required this.md5,
  });

  Future<void> _addToFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final favoritesCollection = userDoc.collection('favorites');
      await favoritesCollection.doc(md5).set({
        'title': title,
        'author': author,
        'imageUrl': imageUrl,
        'size': size,
        'genre': genre,
        'year': year,
        'format': format,
        'md5': md5,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: _addToFavorites,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyles.title,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Autor: $author',
              style: TextStyles.subtitle,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Género: $genre',
              style: TextStyles.subtitle,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Año: $year',
              style: TextStyles.subtitle,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Formato: $format',
              style: TextStyles.subtitle,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tamaño: $size',
              style: TextStyles.subtitle,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final downloadLinks = await AnnasArchiveApi.downloadBook(md5);
                if (downloadLinks?.isNotEmpty ?? false) {
                  final url = downloadLinks.first;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                } else {
                  // Manejar el caso en que no haya enlaces de descarga
                  print('No download links available');
                }
              },
              child: const Text('Descargar'),
            ),
          ],
        ),
      ),
    );
  }
}