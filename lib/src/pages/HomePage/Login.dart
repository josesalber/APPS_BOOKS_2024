import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APPrende+',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('APPrende+'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INICIA SECION'),
              Tab(text: 'REGISTRATE'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginTab(),
            RegisterTab(),
          ],
        ),
      ),
    );
  }
}

class LoginTab extends StatelessWidget {
  const LoginTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Usuario',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
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
  const RegisterTab({super.key});

  @override
  _RegisterTabState createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  String selectedInstitution = 'Select';
  String selectedSchoolYear = '1';
  String selectedCollegeCycle = '1';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Apellidos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedInstitution,
              items: ['Select', 'School', 'University']
                  .map((institution) => DropdownMenuItem(
                        value: institution,
                        child: Text(institution),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedInstitution = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'INSITUCION',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedInstitution == 'School')
              DropdownButtonFormField<String>(
                value: selectedSchoolYear,
                items: List.generate(
                  11,
                  (index) => DropdownMenuItem(
                    value: '${index + 1}',
                    child: Text('Año ${index + 1}'),
                  ),
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSchoolYear = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Año escolar 7 a 11 (1ro a 5to)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            if (selectedInstitution == 'University')
              DropdownButtonFormField<String>(
                value: selectedCollegeCycle,
                items: List.generate(
                  10,
                  (index) => DropdownMenuItem(
                    value: '${index + 1}',
                    child: Text('Ciclo ${index + 1}'),
                  ),
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCollegeCycle = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'College Cycle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Acción de registro
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: const Text('REGISTRAR'),
            ),
          ],
        ),
      ),
    );
  }
}
