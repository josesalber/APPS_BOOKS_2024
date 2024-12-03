import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/services/annas_archive_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marquee/marquee.dart';

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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: Marquee(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            scrollAxis: Axis.horizontal,
            blankSpace: 20.0,
            velocity: 30.0,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10.0,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final imageHeight = isTablet ? 300.0 : 200.0;
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: imageHeight,
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
                      style: TextStyles.title.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Autor: $author',
                      style: TextStyles.subtitle.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Género: $genre',
                      style: TextStyles.subtitle.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Año: $year',
                      style: TextStyles.subtitle.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Formato: $format',
                      style: TextStyles.subtitle.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Tamaño: $size',
                      style: TextStyles.subtitle.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        final downloadLinks = await AnnasArchiveApi.downloadBook(md5);
                        if (downloadLinks?.isNotEmpty ?? false) {
                          final url = downloadLinks.first;
                          await _launchUrl(url);
                        } else {
                          print('No download links available');
                        }
                      },
                      child: const Text('Descargar'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}