import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/course.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart'; 
import 'package:flutter_application_1/src/pages/HomePage/widgets/course_info_row.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marquee/marquee.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final daysLeft = course.getExpiryTime();
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: Marquee(
            text: course.title,
            style: TextStyles.title,
            scrollAxis: Axis.horizontal,
            blankSpace: 20.0,
            velocity: 30.0,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10.0,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Image.network(
                          course.previewImage,
                          height: isTablet ? 300 : 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: isTablet ? 300 : 200,
                              width: double.infinity,
                              color: Colors.grey,
                              child: const Center(
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
                            icon: const Icon(Icons.favorite_border, color: Colors.white),
                            onPressed: () async {
                              await _addToFavorites(context);
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
                            data: course.description, 
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
          );
        },
      ),
    );
  }

  Future<void> _addToFavorites(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final coursesCollection = userDoc.collection('courses');
      await coursesCollection.doc(course.title).set({
        'title': course.title,
        'author': course.author,
        'category': course.category,
        'previewImage': course.previewImage,
        'couponUrl': course.couponUrl,
        'rating': course.rating,
        'expiredDate': course.expiredDate.toIso8601String(),
        'students': course.students,
        'contentLength': course.contentLength,
        'heading': course.heading,
        'description': course.description,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curso agregado a favoritos')),
      );
    }
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