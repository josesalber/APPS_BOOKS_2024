import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'HomePage.dart';
import 'UserPage.dart';
import 'widgets/text_styles.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('APPrende+'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INICIA SESIÓN'),
              Tab(text: 'REGÍSTRATE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoginTab(emailController: emailController),
            RegisterTab(emailController: emailController),
          ],
        ),
      ),
    );
  }
}

class LoginTab extends StatefulWidget {
  final TextEditingController emailController;

  const LoginTab({super.key, required this.emailController});

  @override
  _LoginTabState createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.emailController.text,
        password: _passwordController.text,
      );

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists && userDoc.data()!['status'] == 0) {
        await FirebaseAuth.instance.signOut();
        _showErrorSnackBar('Esta cuenta no existe.');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            _showErrorSnackBar('La dirección de correo electrónico está mal formateada.');
            break;
          case 'wrong-password':
            _showErrorSnackBar('La contraseña es incorrecta.');
            break;
          default:
            _showErrorSnackBar('Error: ${e.message}');
        }
      } else {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'APP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              ),
              Text(
                'RENDE+',
                style: TextStyle(
                  color: Color(0xFF36E58C),
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                '¡Bienvenido a APPrende+!',
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                speed: const Duration(milliseconds: 100),
              ),
              TypewriterAnimatedText(
                'Inicia sesión para continuar',
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
            pause: const Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: widget.emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _signIn,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            child: const Text('ENTRAR'),
          ),
        ],
      ),
    );
  }
}

class RegisterTab extends StatefulWidget {
  final TextEditingController emailController;

  const RegisterTab({super.key, required this.emailController});

  @override
  _RegisterTabState createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _register() async {
    final email = widget.emailController.text;
    final password = _passwordController.text;

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Por favor ingrese un correo electrónico válido.');
      return;
    }

    if (!_isValidPassword(password)) {
      _showErrorSnackBar('La contraseña debe tener al menos 6 caracteres, incluyendo una letra mayúscula y un carácter especial.');
      return;
    }

    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        _showErrorSnackBar('El correo electrónico ya está registrado.');
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cambiar a la pestaña de inicio de sesión con el correo ya ingresado
      widget.emailController.text = email;
      _passwordController.clear();
      DefaultTabController.of(context)?.animateTo(0);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            _showErrorSnackBar('La dirección de correo electrónico está mal formateada.');
            break;
          case 'weak-password':
            _showErrorSnackBar('La contraseña debe tener al menos 6 caracteres.');
            break;
          case 'email-already-in-use':
            _showErrorSnackBar('El correo electrónico ya está registrado.');
            break;
          default:
            _showErrorSnackBar('Error: ${e.message}');
        }
      } else {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@(gmail\.com|outlook\.com|yahoo\.com)$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'APP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              ),
              Text(
                'RENDE+',
                style: TextStyle(
                  color: Color(0xFF36E58C),
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                '¡Bienvenido a APPrende+!',
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                speed: const Duration(milliseconds: 100),
              ),
              TypewriterAnimatedText(
                'Regístrate para comenzar',
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
            pause: const Duration(milliseconds: 1000),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: widget.emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            child: const Text('REGISTRAR'),
          ),
        ],
      ),
    );
  }
}