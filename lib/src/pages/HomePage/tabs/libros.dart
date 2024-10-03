import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LibrosPage extends StatefulWidget {
  const LibrosPage({super.key});

  @override
  _LibrosPageState createState() => _LibrosPageState();
}

class _LibrosPageState extends State<LibrosPage> {
  List<dynamic> libros = [];

  @override
  void initState() {
    super.initState();
    fetchLibros();
  }

  Future<void> fetchLibros() async {
    final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=flutter'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        libros = data['items'];
      });
    } else {
      throw Exception('Error al cargar libros');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: libros.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: libros.length,
              itemBuilder: (context, index) {
                final libro = libros[index];
                final volumeInfo = libro['volumeInfo'];
                final title = volumeInfo['title'];
                final authors =
                    volumeInfo['authors']?.join(', ') ?? 'Desconocido';
                final publishedDate =
                    volumeInfo['publishedDate'] ?? 'Desconocido';
                final imageUrl = volumeInfo['imageLinks']?['thumbnail'] ?? '';

                return GestureDetector(
                  onTap: () {
                    final previewLink = volumeInfo['previewLink'];
                    if (previewLink != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleLibroPage(
                            imageUrl: imageUrl,
                            titulo: title,
                            autor: authors,
                            materia: 'Programación',
                            anio: publishedDate,
                            previewLink: previewLink,
                          ),
                        ),
                      );
                    }
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
                                fit: BoxFit.cover,
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Autor: $authors',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Publicado: $publishedDate',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class DetalleLibroPage extends StatelessWidget {
  final String imageUrl;
  final String titulo;
  final String autor;
  final String materia;
  final String anio;
  final String previewLink;

  const DetalleLibroPage({
    super.key,
    required this.imageUrl,
    required this.titulo,
    required this.autor,
    required this.materia,
    required this.anio,
    required this.previewLink,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200, // Ajusta el tamaño según lo necesites
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit
                      .contain, // Esto asegura que la imagen se vea completa
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Autor: $autor',
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Materia: $materia',
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Año de Publicación: $anio',
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Abrir el enlace de previsualización en el navegador
                launchURL(previewLink);
              },
              child: const Text('Leer en Google Books'),
            ),
          ],
        ),
      ),
    );
  }

  void launchURL(String url) {
    // Puedes usar el paquete url_launcher para abrir la URL en el navegador
    // launch(url);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libros de Flutter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LibrosPage(),
    );
  }
}
