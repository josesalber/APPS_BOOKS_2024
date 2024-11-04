import 'package:flutter/material.dart';
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
                    onPressed: () {
                      // Acción para marcar como favorito
                    },
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
                // Abre el primer enlace de descarga en el navegador
                if (downloadLinks.isNotEmpty) {
                  final url = downloadLinks.first;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
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