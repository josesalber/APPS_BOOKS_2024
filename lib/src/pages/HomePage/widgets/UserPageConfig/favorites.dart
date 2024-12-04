import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addToFavorites(Map<String, dynamic> book) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final favoritesCollection = userDoc.collection('favorites');
    await favoritesCollection.doc(book['md5']).set({
      'title': book['title'] ?? '',
      'author': book['author'] ?? '',
      'imgUrl': book['imgUrl'] ?? '',
      'size': book['size'] ?? '',
      'genre': book['genre'] ?? '',
      'year': book['year'] ?? '',
      'format': book['format'] ?? '',
      'md5': book['md5'] ?? '',
    });
  }
}