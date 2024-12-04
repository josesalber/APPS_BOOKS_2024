import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> addToFavorites(BuildContext context, Map<String, dynamic> book) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final favoritesCollection = userDoc.collection('favorites');
    final docSnapshot = await favoritesCollection.doc(book['md5']).get();

    if (docSnapshot.exists) {
      // Mostrar SnackBar si el libro ya está en favoritos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este libro ya está en favoritos'),
        ),
      );
    } else {
      // Agregar el libro a favoritos
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

      // Mostrar SnackBar si el libro se ha agregado a favoritos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro agregado a favoritos'),
        ),
      );
    }
  }
}