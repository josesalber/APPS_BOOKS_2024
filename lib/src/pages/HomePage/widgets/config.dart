import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/src/pages/HomePage/Login.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/UserPageConfig/ProfileCard.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/UserPageConfig/admin_settings_page.dart';
import 'package:flutter_application_1/services/fortnite_api.dart';
import 'text_styles.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _institutionType = 'colegio';
  String? _university;
  List<String> _coursePreferences = [];
  List<String> _bookPreferences = [];
  String _role = 'user'; // Rol del usuario
  String? _profileImageId; // ID de la imagen de perfil

  final List<String> _institutionTypes = ['colegio', 'tecnico', 'universitario', 'otros'];
  final List<String> _universities = [
    'AUNA',
    'PUCP', // Pontificia Universidad Católica del Perú
    'UNMSM', // Universidad Nacional Mayor de San Marcos
    'UNI', // Universidad Nacional de Ingeniería
    'UPN', // Universidad Privada del Norte
    'UPC', // Universidad Peruana de Ciencias Aplicadas
    'USMP', // Universidad de San Martín de Porres
    'UNFV', // Universidad Nacional Federico Villarreal
    'UTP', // Universidad Tecnológica del Perú
    'UCSM', // Universidad Católica de Santa María
    'UCSP', // Universidad Católica San Pablo
    'USIL', // Universidad San Ignacio de Loyola
    'Universidad de Lima', // Universidad de Lima
    'Universidad del Pacífico', // Universidad del Pacífico
    'Universidad de Piura', // Universidad de Piura
    'Universidad Nacional de Piura', // Universidad Nacional de Piura
    'UNSA', // Universidad Nacional de San Agustín
    'UCV', // Universidad César Vallejo
    'UNALM', // Universidad Nacional Agraria La Molina
    'UNSAAC', // Universidad Nacional San Antonio Abad del Cusco
    'UCSUR', // Universidad Científica del Sur
    'Universidad Esan', // Universidad Esan
    'UJCM', // Universidad José Carlos Mariátegui
    'UNAMAD', // Universidad Nacional Amazónica de Madre de Dios
    'UNAJ', // Universidad Nacional de Juliaca
    'UNH', // Universidad Nacional Hermilio Valdizán
    'UNAC', // Universidad Nacional del Callao
    'UNTELS', // Universidad Nacional Tecnológica de Lima Sur
    'UNAC', // Universidad Nacional del Callao
    'Universidad Nacional de Cañete', // Universidad Nacional de Cañete
    'UNC', // Universidad Nacional de Cajamarca
    'UNJBG', // Universidad Nacional Jorge Basadre Grohmann
    'UNI', // Universidad Nacional de Ingeniería
  ];

  final List<String> _courseCategories = [
    'Personal Development', 'Marketing', 'Business', 'Development', 'IT & Software',
    'Teaching & Academics', 'Photography & Video', 'Finance & Accounting', 'Office Productivity',
    'Design', 'Health & Fitness', 'Lifestyle'
  ];

  final List<String> _bookCategories = [
    'programacion', 'ciencia ficcion', 'historia', 'arte', 'ciencia', 'matematicas',
    'literatura', 'filosofia', 'musica', 'deportes', 'novelas', 'comic', 'magazine'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _institutionType = data['institutionType'] ?? 'colegio';
        _university = data['university'];
        _role = data['role'] ?? 'user'; // Obtener el rol del usuario
        _profileImageId = data['profileImageId']; // Obtener la ID de la imagen de perfil
        setState(() {});
      }

      final preferencesSnapshot = await userDoc.collection('user_data').doc('preferences').get();
      if (preferencesSnapshot.exists) {
        final preferencesData = preferencesSnapshot.data()!;
        _coursePreferences = List<String>.from(preferencesData['coursePreferences'] ?? []);
        _bookPreferences = List<String>.from(preferencesData['bookPreferences'] ?? []);
        setState(() {});
      }
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Guardar datos personales en la colección 'users'
        await userDoc.set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'age': int.tryParse(_ageController.text),
          'institutionType': _institutionType,
          'university': _university,
          'role': _role, // Guardar el rol del usuario
          'profileImageId': _profileImageId, // Guardar la ID de la imagen de perfil
          'status': 1, // Establecer el estado como activo por defecto
        });

        // Guardar preferencias en la subcolección 'user_data/preferences'
        await userDoc.collection('user_data').doc('preferences').set({
          'coursePreferences': _coursePreferences,
          'bookPreferences': _bookPreferences,
        });

        // Mostrar SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos guardados!')),
        );

        Navigator.pop(context);
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  Future<void> _selectProfileImage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final images = await FortniteApi.fetchCharacterImages();
      Navigator.of(context).pop(); // Cerrar el indicador de carga
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Seleccionar Foto de Perfil'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _profileImageId = images[index]['id'];
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Foto de perfil seleccionada')),
                      );
                    },
                    child: Image.network(images[index]['icon'] ?? ''),
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar el indicador de carga en caso de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar imágenes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ProfileCard(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                university: _university,
                email: FirebaseAuth.instance.currentUser?.email,
                role: _role, // Pasar el rol del usuario
                profileImageUrl: _profileImageId != null
                    ? 'https://fortnite-api.com/images/cosmetics/br/${_profileImageId!.toLowerCase()}/icon.png'
                    : null, // Pasar la URL de la imagen de perfil
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _selectProfileImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Color del texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text('Seleccionar Foto de Perfil'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Edad',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su edad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _institutionType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Institución',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                items: _institutionTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _institutionType = value!;
                    if (_institutionType != 'universitario') {
                      _university = null;
                    }
                  });
                },
                style: const TextStyle(color: Colors.white), // Cambia el color del texto seleccionado a blanco
                dropdownColor: Colors.black, // Cambia el color de fondo del menú desplegable
              ),
              if (_institutionType == 'universitario')
                const SizedBox(height: 16.0),
              if (_institutionType == 'universitario')
                DropdownButtonFormField<String>(
                  value: _university,
                  decoration: InputDecoration(
                    labelText: 'Universidad',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  items: _universities.map((university) {
                    return DropdownMenuItem(
                      value: university,
                      child: Text(university),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _university = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white), // Cambia el color del texto seleccionado a blanco
                  dropdownColor: Colors.black, // Cambia el color de fondo del menú desplegable
                ),
              const SizedBox(height: 16.0),
              const Text('Preferencias de Cursos', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: _courseCategories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _coursePreferences.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_coursePreferences.length < 3) {
                            _coursePreferences.add(category);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Solo puedes seleccionar hasta 3 categorías.'),
                              ),
                            );
                          }
                        } else {
                          _coursePreferences.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              const Text('Preferencias de Libros', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: _bookCategories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _bookPreferences.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_bookPreferences.length < 3) {
                            _bookPreferences.add(category);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Solo puedes seleccionar hasta 3 categorías.'),
                              ),
                            );
                          }
                        } else {
                          _bookPreferences.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Color del texto
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 16.0),
              if (_role == 'admin') 
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminSettingsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Color del texto
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text('Ajustes de Administrador'),
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red, // Color del texto
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}