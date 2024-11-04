import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/services/annas_archive_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LibrosPage extends StatefulWidget {
  const LibrosPage({super.key});

  @override
  _LibrosPageState createState() => _LibrosPageState();
}

class _LibrosPageState extends State<LibrosPage> {
  List<dynamic> libros = [];
  TextEditingController searchController = TextEditingController();
  List<String> currentTopics = [];
  String selectedCategory = "Todos";
  List<String> categories = ["Todos"];
  String searchQuery = "";
  bool isLoading = false;
  bool isConnected = true;

  final List<String> topics = [
    'programación',
    'ciencia ficción',
    'historia',
    'arte',
    'ciencia',
    'matemáticas',
    'literatura',
    'filosofía',
    'música',
    'deportes',
    'novelas',
    'comic',
    'magazine'
  ];

  final Map<String, String> categorySearchTerms = {
    'programación': 'programming, programación',
    'ciencia ficción': 'science fiction, ciencia ficción',
    'historia': 'history, historia',
    'arte': 'art, arte',
    'ciencia': 'science, ciencia',
    'matemáticas': 'mathematics, matemáticas',
    'literatura': 'literature, literatura',
    'filosofía': 'philosophy, filosofía',
    'música': 'music, música',
    'deportes': 'sports, deportes',
    'novelas': 'fiction, novelas',
    'comic': 'comic, cómic',
    'magazine': 'magazine, revista'
  };

  @override
  void initState() {
    super.initState();
    _checkAndUpdateBooks();
  }

  Future<void> _checkAndUpdateBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('lastUpdate');
    final now = DateTime.now();

    if (lastUpdate == null || now.difference(DateTime.parse(lastUpdate)).inHours >= 12) {
      _selectRandomTopics();
      await _fetchBooks();
      prefs.setString('lastUpdate', now.toIso8601String());
    } else {
      _selectRandomTopics();
      await _fetchBooks();
    }
  }

  void _selectRandomTopics() {
    final random = Random();
    currentTopics = List.generate(3, (_) => topics[random.nextInt(topics.length)]);
  }

  Future<void> _fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> allBooks = [];
    for (String topic in currentTopics) {
      final results = await AnnasArchiveApi.searchBooks(categorySearchTerms[topic] ?? topic);
      allBooks.addAll(results);
    }
    setState(() {
      libros = allBooks;
      categories = ["Todos"];
      categories.addAll(topics);
      isLoading = false;
    });
  }

  void _filterBooks() {
    setState(() {
      libros = libros.where((book) {
        final matchesCategory = selectedCategory == "Todos" || book['genre'] == selectedCategory || book['title'].toLowerCase().contains(selectedCategory.toLowerCase());
        final matchesSearch = book['title'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _filterBooksByCategory(String category) async {
    setState(() {
      selectedCategory = category;
    });
    if (category == "Todos" && searchController.text.isEmpty) {
      await _checkAndUpdateBooks();
    } else {
      await searchBooks();
    }
  }

  Future<void> searchBooks() async {
    setState(() {
      isLoading = true;
    });
    final query = searchController.text;
    String searchTerm;
    if (selectedCategory == "Todos") {
      searchTerm = query.isNotEmpty ? query : "";
    } else {
      searchTerm = query.isNotEmpty ? query : categorySearchTerms[selectedCategory] ?? selectedCategory;
    }
    final results = await AnnasArchiveApi.searchBooks(searchTerm, category: selectedCategory == "Todos" ? "all" : selectedCategory);
    setState(() {
      libros = results.where((book) {
        final matchesSearch = book['title'].toLowerCase().contains(query.toLowerCase());
        return matchesSearch;
      }).toList();
      isLoading = false;
    });
  }

  void _clearSearch() {
    searchController.clear();
    if (selectedCategory == "Todos") {
      _checkAndUpdateBooks();
    } else {
      searchBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _checkAndUpdateBooks,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : libros.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          color: Colors.white,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedCategory == "Todos"
                              ? 'El libro que buscas no está disponible :('
                              : 'El libro que buscas no se encuentra en esta categoría :(',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = "Todos";
                              _clearSearch();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 241, 241, 243),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Borrar Filtros',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
                                      width: 100, // Forzar un tamaño estándar
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
                                  // Acción para marcar como favorito
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Column(
            children: [
              const Text(
                'Libros gratuitos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSearchField(),
              const SizedBox(height: 10),
              _buildCategoryFilter(),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Buscar libros...',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: _clearSearch,
        ),
      ),
      onSubmitted: (value) {
        searchQuery = value;
        if (value.isEmpty) {
          _clearSearch();
        } else {
          searchBooks();
        }
      },
    );
  }

  Container _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF302f3c),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text(
            'Filtrar por:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6c61af),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _filterBooksByCategory(value!);
                  },
                  dropdownColor: const Color(0xFF6c61af),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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