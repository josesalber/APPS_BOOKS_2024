import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart'; // Importa el archivo de estilos
import 'package:flutter_application_1/src/pages/HomePage/widgets/course_info_row.dart'; // Importa el nuevo widget

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysLeft = course.getExpiryTime();
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title, style: TextStyles.title),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80.0), // Espacio para el botón
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      course.previewImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey,
                          child: Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {
                          // Acción del botón de corazón
                        },
                      ),
                    ),
                    if (daysLeft.isNotEmpty)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            daysLeft,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyles.title,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        course.heading,
                        style: TextStyles.subtitle,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: course.getCategoryColor(),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          course.category,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard(
                            context,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: course.getRatingStars(),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${course.rating.toStringAsFixed(1)}/5",
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildInfoCard(
                            context,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Duración",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${course.contentLength} minutos",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              const url = 'https://www.udemy.com/';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'No se pudo abrir el enlace de Udemy';
                              }
                            },
                            child: _buildInfoCard(
                              context,
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: const DecorationImage(
                                    image: NetworkImage('https://logowik.com/content/uploads/images/udemy-new-20212512.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CourseInfoRow(course: course),
                      const SizedBox(height: 10),
                      Html(
                        data: course.description, // Convierte HTML a texto legible
                        style: {
                          "body": Style.fromTextStyle(TextStyles.bodyText),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0), const Color(0xFF1c1a29)],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final Uri url = Uri.parse(course.couponUrl);
                  if (await canLaunch(url.toString())) {
                    await launch(url.toString());
                  } else {
                    throw 'No se pudo abrir el enlace del curso';
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6c61af),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OBTENER CURSO'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Widget child) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 20,
      height: 73,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF6c61af),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(child: child),
    );
  }
}