import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../text_styles.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserRecord> _users = [];
  List<UserRecord> _filteredUsers = [];
  User? _currentUser;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      setState(() {
        _users = usersSnapshot.docs
            .map((doc) => UserRecord.fromDocument(doc))
            .where((user) => user.uid != _currentUser?.uid)
            .toList();
        _filteredUsers = _users;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.firstName.toLowerCase().contains(query) ||
               user.lastName.toLowerCase().contains(query) ||
               user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado')),
      );
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> _updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': role});
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol actualizado a $role')),
      );
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<void> _banUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'banned': true});
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario baneado')),
      );
    } catch (e) {
      print('Error banning user: $e');
    }
  }

  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de restablecimiento de contraseña enviado')),
      );
    } catch (e) {
      print('Error resetting password: $e');
    }
  }

  void _editUser(UserRecord user) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController firstNameController = TextEditingController(text: user.firstName);
        final TextEditingController lastNameController = TextEditingController(text: user.lastName);
        final TextEditingController emailController = TextEditingController(text: user.email);

        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firestore.collection('users').doc(user.uid).update({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                  });
                  _fetchUsers();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario actualizado')),
                  );
                } catch (e) {
                  print('Error editing user: $e');
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de Administrador', style: TextStyles.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Usuarios', style: TextStyles.subtitle),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar usuarios',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: TextStyles.bodyText,
                          ),
                          if (user.role == 'admin')
                            Container(
                              margin: const EdgeInsets.only(left: 8.0),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(color: Colors.white, fontSize: 12.0),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email, style: TextStyles.bodyText),
                          Text('UID: ${user.uid}', style: TextStyles.bodyText),
                          Text('Banned: ${user.banned}', style: TextStyles.bodyText),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'delete':
                              _deleteUser(user.uid);
                              break;
                            case 'edit':
                              _editUser(user);
                              break;
                            case 'assignRole':
                              _updateUserRole(user.uid, user.role == 'admin' ? 'user' : 'admin');
                              break;
                            case 'ban':
                              _banUser(user.uid);
                              break;
                            case 'resetPassword':
                              _resetPassword(user.email);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          PopupMenuItem(
                            value: 'assignRole',
                            child: Text(user.role == 'admin' ? 'Revocar privilegios de administrador' : 'Asignar Rol de Admin'),
                          ),
                          const PopupMenuItem(
                            value: 'ban',
                            child: Text('Banear'),
                          ),
                          const PopupMenuItem(
                            value: 'resetPassword',
                            child: Text('Restablecer Contraseña'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserRecord {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool banned;

  UserRecord({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.banned,
  });

  factory UserRecord.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserRecord(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      banned: data['banned'] ?? false,
    );
  }
}