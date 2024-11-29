import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../text_styles.dart';

class AddNews extends StatefulWidget {
  const AddNews({super.key});

  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _deleteNews(String id) async {
    try {
      await _firestore.collection('Noticias').doc(id).update({
        'status': 0,
        'deletionTimestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Noticia eliminada')),
      );
    } catch (e) {
      print('Error deleting news: $e');
    }
  }

  Future<void> _deleteNewsPermanently(String id) async {
    try {
      await _firestore.collection('Noticias').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Noticia eliminada definitivamente')),
      );
    } catch (e) {
      print('Error deleting news permanently: $e');
    }
  }

  Future<void> _restoreNews(String id) async {
    try {
      await _firestore.collection('Noticias').doc(id).update({
        'status': 1,
        'deletionTimestamp': null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Noticia restaurada')),
      );
    } catch (e) {
      print('Error restoring news: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Administrador de Noticias',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Noticias').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar noticias'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay noticias disponibles'));
                }

                final newsDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: newsDocs.length,
                  itemBuilder: (context, index) {
                    final news = newsDocs[index].data() as Map<String, dynamic>;
                    final id = newsDocs[index].id;
                    final isDeleted = news['status'] == 0;

                    return Card(
                      color: isDeleted ? Colors.red : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            news['banner'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              news['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isDeleted)
                                TextButton(
                                  onPressed: () => _restoreNews(id),
                                  child: const Text('Restaurar'),
                                ),
                              if (!isDeleted)
                                TextButton(
                                  onPressed: () => _launchUrl('https://your-web-url.com/edit_news?id=$id'),
                                  child: const Text('Editar'),
                                ),
                              TextButton(
                                onPressed: () => isDeleted ? _deleteNewsPermanently(id) : _deleteNews(id),
                                child: Text(isDeleted ? 'Eliminar Definitivamente' : 'Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton.extended(
            onPressed: () => _launchUrl('https://your-web-url.com/add_news'),
            label: const Text('Agregar Noticia'),
            icon: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}