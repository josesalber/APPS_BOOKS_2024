import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Login.dart';
import 'widgets/text_styles.dart';
import 'widgets/app_styles.dart';
import 'widgets/detalle_libro.dart'; 
import 'package:flutter_application_1/services/annas_archive_api.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _showCourses = true;
  User? user;
  List<Map<String, dynamic>> favoriteBooks = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchFavoriteBooks();
  }

  Future<void> _fetchFavoriteBooks() async {
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final favoritesCollection = userDoc.collection('favorites');
      final snapshot = await favoritesCollection.get();
      setState(() {
        favoriteBooks = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        _filteredBooks = favoriteBooks;
      });
    }
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = favoriteBooks;
      } else {
        _filteredBooks = favoriteBooks.where((book) {
          final titleLower = book['title'].toLowerCase();
          final authorLower = book['author'].toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower) || authorLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _removeFromFavorites(String md5) async {
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final favoritesCollection = userDoc.collection('favorites');
      await favoritesCollection.doc(md5).delete();
      setState(() {
        favoriteBooks.removeWhere((book) => book['md5'] == md5);
        _filteredBooks.removeWhere((book) => book['md5'] == md5);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E), 
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'APP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'RENDE+',
              style: TextStyle(
                color: Color(0xFF36E58C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Acción para el botón de configuración
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildCategoryButtons(),
            const SizedBox(height: 10), // Reducir el espacio entre los switches y los cuadros
            _buildSwitches(),
            const SizedBox(height: 10), // Reducir el espacio entre los switches y los cuadros
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: _showCourses ? _buildCoursesContainer() : _buildLibraryContainer(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text('CERRAR SESIÓN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 109, 96, 175),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/user_image.png'), // Reemplaza con tu imagen
            radius: 30,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.email ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                '',
                style: TextStyle(color: Colors.white70),
              ),
              const Text(
                '',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
    final categories = ['Música', 'Programación', 'Diseño'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories.map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitches() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSwitchButton('Mis cursos', _showCourses, true),
        _buildSwitchButton('Mi biblioteca', !_showCourses, false),
      ],
    );
  }

  Widget _buildSwitchButton(String title, bool isSelected, bool isLeft) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCourses = title == 'Mis cursos';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 109, 96, 175) : Colors.black54,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCoursesContainer() {
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

  Widget _buildLibraryContainer() {
    return SizedBox(
      width: double.infinity,
      height: 400, // Aumentar la altura de los cuadros
      child: Container(
        key: const ValueKey('library'),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Biblioteca',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _filterBooks('');
                      }
                    });
                  },
                ),
              ],
            ),
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar libros...',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: _filterBooks,
                ),
              ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return _buildDismissibleBookCard(book);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleBookCard(Map<String, dynamic> book) {
    return Dismissible(
      key: Key(book['md5']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      onDismissed: (direction) {
        _removeFromFavorites(book['md5']);
      },
      child: _buildBookCard(book),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleLibroPage(
              title: book['title'],
              author: book['author'],
              imageUrl: book['imgUrl'],
              size: book['size'],
              genre: book['genre'],
              year: book['year'],
              format: book['format'],
              md5: book['md5'],
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
                    book['title'],
                    style: TextStyles.title,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Autor: ${book['author']}',
                    style: TextStyles.bodyText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}