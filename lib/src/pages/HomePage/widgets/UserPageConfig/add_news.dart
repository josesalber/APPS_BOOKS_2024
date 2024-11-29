import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AddNews extends StatefulWidget {
  const AddNews({super.key});

  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bannerController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  Map<String, dynamic>? _latestNews;

  Future<void> _addNews() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    final newsData = {
      'banner': _bannerController.text,
      'title': _titleController.text,
      'info': _infoController.text,
      'link': _linkController.text,
      'adminId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('Noticias').add(newsData);
      setState(() {
        _latestNews = newsData;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Noticia agregada')),
      );
      _bannerController.clear();
      _titleController.clear();
      _infoController.clear();
      _linkController.clear();
    } catch (e) {
      print('Error adding news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agregar Noticia', style: TextStyles.subtitle),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _bannerController,
                  decoration: const InputDecoration(
                    labelText: 'URL del Banner',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la URL del banner';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _infoController,
                  decoration: const InputDecoration(
                    labelText: 'Información',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la información';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: 'Enlace',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el enlace';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addNews,
                  child: const Text('Agregar Noticia'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_latestNews != null) ...[
            const Text('Previsualización', style: TextStyles.subtitle),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    _latestNews!['banner'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _latestNews!['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_latestNews!['info']),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () async {
                            final url = _latestNews!['link'];
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: const Text('Ir al enlace'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}