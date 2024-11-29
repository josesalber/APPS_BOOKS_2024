import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleNoticiaPage extends StatelessWidget {
  final String banner;
  final String title;
  final String info;
  final String link;

  const DetalleNoticiaPage({
    super.key,
    required this.banner,
    required this.title,
    required this.info,
    required this.link,
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
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                image: DecorationImage(
                  image: NetworkImage(banner),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              info,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (await canLaunch(link)) {
                  await launch(link);
                } else {
                  throw 'Could not launch $link';
                }
              },
              child: const Text('Ir al enlace'),
            ),
          ],
        ),
      ),
    );
  }
}