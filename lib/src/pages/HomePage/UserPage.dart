import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/model/course.dart';
import 'widgets/config.dart'; 
import 'widgets/UserPageConfig/ProfileCard.dart';
import 'widgets/UserPageConfig/CategoryButtons.dart';
import 'widgets/UserPageConfig/SwitchButtons.dart';
import 'widgets/UserPageConfig/CoursesContainer.dart';
import 'widgets/UserPageConfig/LibraryContainer.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _showCourses = true;
  User? user;
  List<Map<String, dynamic>> favoriteBooks = [];
  List<Course> favoriteCourses = [];
  List<Course> filteredCourses = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBooks = [];
  String? _firstName;
  String? _lastName;
  String? _university;
  String? _role;
  String? _profileImageUrl; 
  List<String> _coursePreferences = [];
  List<String> _bookPreferences = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchFavoriteBooks();
    _fetchFavoriteCourses();
    _fetchUserInfo();
    _fetchPreferences();
  }

  Future<void> _fetchPreferences() async {
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final preferencesSnapshot = await userDoc.collection('user_data').doc('preferences').get();
      if (preferencesSnapshot.exists) {
        final preferencesData = preferencesSnapshot.data()!;
        setState(() {
          _coursePreferences = List<String>.from(preferencesData['coursePreferences'] ?? []);
          _bookPreferences = List<String>.from(preferencesData['bookPreferences'] ?? []);
        });
      }
    }
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

  Future<void> _fetchFavoriteCourses() async {
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final coursesCollection = userDoc.collection('courses');
      final snapshot = await coursesCollection.get();
      setState(() {
        favoriteCourses = snapshot.docs.map((doc) => Course.fromJson(doc.data())).toList();
        filteredCourses = favoriteCourses;
      });
    }
  }

  Future<void> _fetchUserInfo() async {
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          _firstName = data['firstName'];
          _lastName = data['lastName'];
          _university = data['university'];
          _role = data['role'];
          _profileImageUrl = data['profileImageId'] != null
              ? 'https://fortnite-api.com/images/cosmetics/br/${data['profileImageId'].toLowerCase()}/icon.png'
              : null; 
        });
      }
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

  void _filterCourses(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCourses = favoriteCourses;
      } else {
        filteredCourses = favoriteCourses.where((course) {
          final titleLower = course.title.toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfigPage()),
              ).then((_) {
                _fetchUserInfo();
                _fetchFavoriteCourses();
                _fetchPreferences();
              }); 
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
            ProfileCard(
              firstName: _firstName,
              lastName: _lastName,
              university: _university,
              email: user?.email,
              role: _role, 
              profileImageUrl: _profileImageUrl, 
            ),
            const SizedBox(height: 20),
            CategoryButtons(categories: _showCourses ? _coursePreferences : _bookPreferences),
            const SizedBox(height: 10), 
            SwitchButtons(
              showCourses: _showCourses,
              onSwitch: (title) {
                setState(() {
                  _showCourses = title == 'Mis cursos';
                });
              },
            ),
            const SizedBox(height: 10), 
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
                  child: _showCourses
                      ? CoursesContainer(
                          favoriteCourses: filteredCourses,
                          onRemove: _removeFromFavorites,
                          searchController: _searchController,
                          onSearch: _filterCourses,
                          isSearching: _isSearching,
                          filteredCourses: filteredCourses,
                        )
                      : LibraryContainer(
                          isSearching: _isSearching,
                          searchController: _searchController,
                          onSearch: (query) {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _searchController.clear();
                                _filterBooks('');
                              } else {
                                _filterBooks(query);
                              }
                            });
                          },
                          filteredBooks: _filteredBooks,
                          onRemove: _removeFromFavorites,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}